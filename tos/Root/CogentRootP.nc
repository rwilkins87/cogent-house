// -*- c -*-
#include "AM.h"
#include "Serial.h"

module CogentRootP{
  uses
  {
      interface Boot;
      interface SplitControl as SerialControl;
      interface SplitControl as RadioControl;

      interface StdControl as CollectionControl;
      interface RootControl;

      //receive interfaces
      interface Receive as CollectionReceive[am_id_t id];
      interface Packet as RadioPacket;
      interface CollectionPacket;

      // dissemination
      interface DisseminationUpdate<AckMsg> as AckUpdate;
      interface StdControl as DisseminationControl;
      interface Crc as CRCCalc ;

      //data forwarding interfaces
      interface AMSend as UartSend[am_id_t id];
      interface Packet as UartPacket;
      interface AMPacket as UartAMPacket;
      interface Receive as UartAckReceive;

      // queuing
      interface Queue<message_t *>;
      interface Pool<message_t>;

      interface Timer<TMilli> as BlinkTimer;
      interface Leds;
    }
}

implementation
{
  message_t fwdMsg;
  bool fwdBusy;
  uint8_t lastLen;
  int mSeq=0;

  event void Boot.booted()
  {
    call SerialControl.start();
    call RadioControl.start();
    call BlinkTimer.startOneShot(512L);

  }

  event void RadioControl.startDone(error_t error) {
    if (error == FAIL)
      call RadioControl.start();
    else {
      call CollectionControl.start();
      call DisseminationControl.start();
      call RootControl.setRoot();
    }
  }
	
  event void RadioControl.stopDone(error_t error) { }


  //DEAL WITH STATE
  message_t uartmsg;

  task void serialForwardTask() { 
    if (!call Queue.empty() && !fwdBusy) {
      message_t* msg = call Queue.dequeue();
      uint8_t len = call RadioPacket.payloadLength(msg);
      void *radio_payload = call RadioPacket.getPayload(msg, len);
      collection_id_t id = call CollectionPacket.getType(msg);
      am_addr_t src = call CollectionPacket.getOrigin(msg);

      if (radio_payload != NULL) { 
	void *uart_payload;
	memcpy(&uartmsg, radio_payload, len);

	call UartPacket.clear(msg);
	call UartAMPacket.setSource(msg, src);
	uart_payload = call UartPacket.getPayload(msg, len);
	if (uart_payload != NULL) { 
	  memcpy(uart_payload, &uartmsg, len);
      
	  if (call UartSend.send[id](AM_BROADCAST_ADDR, msg, len) == SUCCESS) { 
	    fwdBusy = TRUE;
	  }
	  else { 
#ifdef BLINKY
	    call Leds.led0On();
#endif
	  }
	}
      }
    }
  }
  

  event message_t *CollectionReceive.receive[collection_id_t id](message_t* msg, 
						    void* payload, 
						    uint8_t len)
  {
#ifdef BLINKY
    call Leds.led2Toggle();
#endif
    if (!call Pool.empty() && call Queue.size() < call Queue.maxSize()) { 
      message_t *tmp = call Pool.get();
      call Queue.enqueue(msg);
      if (!fwdBusy) {
	post serialForwardTask();
      }
      return tmp;
    }
    return msg;
  }

  event void UartSend.sendDone[am_id_t id](message_t *msg, error_t error) {
    fwdBusy = FALSE;
    call Pool.put(msg);
    if (! call Queue.empty())
      post serialForwardTask();
  }

  event message_t *UartAckReceive.receive(message_t* msg, void* payload, uint8_t len)
  {    
    AckMsg *ackMsg = payload;
    CRCStruct crs;
    uint16_t crc;

#ifdef BLINKY 
    call Leds.led1Toggle();
#endif
    if (len == sizeof(*ackMsg)) {
      //message is ok calculate crc
      crs.node_id = ackMsg->node_id;
      crs.seq = ackMsg->seq;
      crc = call CRCCalc.crc16(&crs, sizeof crs);
      ackMsg->crc=crc;
      call AckUpdate.change(ackMsg);
    }
    return msg;
  }

  event void SerialControl.startDone(error_t error) {
    fwdBusy = FALSE;
    if (error == FAIL)
      call SerialControl.start();
  }
  event void SerialControl.stopDone(error_t error) { }

  uint8_t blink_state = 0;

  uint8_t gray[] = { 0, 1, 3, 2 };

  event void BlinkTimer.fired() { 
    if (blink_state >= 60) { /* 30 seconds */
      call Leds.set(0);
    }
    else { 
      blink_state++;
      call BlinkTimer.startOneShot(512L);
      call Leds.set(gray[blink_state % (sizeof gray / sizeof gray[0])]);
    }
  }

}
