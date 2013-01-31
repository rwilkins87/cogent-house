// -*- c -*-
#include "../Packets.h"
#include "Collection.h"
#include "PolyClass/horner.c"
#include "CurrentCost/cc_struct.h"
#include "Filter.h"
#include "HeatMeter/hm_struct.h"
#include <stdio.h>
#include <stdint.h>
#ifdef DEBUG
#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#endif 

configuration CogentHouseC {}
implementation
{
  components CogentHouseP, ActiveMessageC, MainC, LedsC, ActiveMessageC as Radio;
#ifdef DEBUG
  components PrintfC;
  components SerialStartC;
#endif
	
  //import timers
  components new TimerMilliC() as SenseTimer;
  components new TimerMilliC() as BlinkTimer;
  components new TimerMilliC() as WarmUpTimer;
  components new TimerMilliC() as SendTimeOutTimer;
  
  components RandomC;


  CogentHouseP.Boot -> MainC.Boot;
  CogentHouseP.SenseTimer -> SenseTimer;
  CogentHouseP.BlinkTimer -> BlinkTimer;
  CogentHouseP.SendTimeOutTimer -> SendTimeOutTimer;
  CogentHouseP.Leds -> LedsC;
  CogentHouseP.RadioControl -> ActiveMessageC;


  // Instantiate and wire our collection service
  components CollectionC;
  components new CollectionSenderC(AM_STATEMSG) as StateSender;

  CogentHouseP.CollectionControl -> CollectionC;
  CogentHouseP.CtpInfo -> CollectionC;
  CogentHouseP.StateSender -> StateSender;

  // ack interfaces
  components new AMReceiverC(AM_ACKMSG) as AckReceiver;
  CogentHouseP.AckReceiver -> AckReceiver;
  components new AMSenderC(AM_ACKMSG) as AckForwarder;
  CogentHouseP.AckForwarder -> AckForwarder;
  CogentHouseP.Packet -> AckForwarder;

  components new HashMapC(HASH_SIZE) as AckHeardMap;
  CogentHouseP.AckHeardMap -> AckHeardMap;

  components new QueueC(AckMsg_t*, RADIO_QUEUE_SIZE) as AckQueue;
  components new PoolC(message_t, RADIO_QUEUE_SIZE) as AckPool;
  CogentHouseP.AckQueue -> AckQueue;
  CogentHouseP.AckPool -> AckPool;


  components CrcC;
  CogentHouseP.CRCCalc -> CrcC;

  //sensing interfaces
  components new SensirionSht11C();
  components new VoltageC() as Volt;
  components new CarbonDioxideC() as CarbonDioxide;
  components new VOCC() as VOC;
  components new AQC() as AQ;
  components HplMsp430InterruptP as GIOInterrupt;
  components HplMsp430GeneralIOC as GIO;

  //import sensing modules
  components ThermalSensingM;
  components AirQualityM;
  components BatterySensingM;

  //sensor readings
  ThermalSensingM.GetTemp -> SensirionSht11C.Temperature;
  ThermalSensingM.GetHum ->SensirionSht11C.Humidity;
  BatterySensingM.GetVoltage -> Volt;
  AirQualityM.GetCO2 -> CarbonDioxide;
  AirQualityM.GetVOC -> VOC;
  AirQualityM.GetAQ -> AQ;
  AirQualityM.CO2On -> GIO.Port23; //set to gio2
  AirQualityM.WarmUpTimer -> WarmUpTimer;


  //set up SI filters + event detectors for co2,temp,hum
  components new FilterM() as TempFilterWrapper;
  components new EventDetectorC(SIP_TEMP_THRESH) as TempDetector; 
#ifdef KALMAN
  components new KalmanC(0.,0.,FALSE,2.864665e-15,0.000410076, 0.) as TempKalmanC;
  TempFilterWrapper.Filter -> TempKalmanC;
  TempDetector -> TempKalmanC.Predict;
#endif
#ifdef DEWMA
  components new DEWMAC(0., 0., FALSE, SIP_TEMP_ALPHA, SIP_TEMP_BETA) as TempDEWMAC;
  TempFilterWrapper.Filter -> TempDEWMAC;
  TempDetector -> TempDEWMAC.Predict;
#endif
  
  TempFilterWrapper.GetSensorValue -> ThermalSensingM.ReadTemp;
  TempFilterWrapper.LocalTime -> HilTimerMilliC;  
  TempDetector.FilterRead -> TempFilterWrapper.Read;
  components new FilterM() as HumFilterWrapper;
  components new EventDetectorC(SIP_HUM_THRESH) as HumDetector;  
#ifdef KALMAN
  components new KalmanC(0.,0.,FALSE, 2.713816e-13,0.01864952, 0.) as HumKalmanC;
  HumFilterWrapper.Filter -> HumKalmanC;
  HumDetector -> HumKalmanC.Predict;
#endif
#ifdef DEWMA
  components new DEWMAC(0., 0., FALSE, SIP_HUM_ALPHA, SIP_HUM_BETA) as HumDEWMAC;  
  HumFilterWrapper.Filter -> HumDEWMAC;
  HumDetector -> HumDEWMAC.Predict;
#endif

  HumFilterWrapper.GetSensorValue -> ThermalSensingM.ReadHum;
  HumFilterWrapper.LocalTime -> HilTimerMilliC;
  HumDetector.FilterRead -> HumFilterWrapper.Read;
 
  components new FilterM() as CO2FilterWrapper;
  components new EventDetectorC(SIP_CO2_THRESH) as CO2Detector; 
#ifdef KALMAN
  components new KalmanC(0.,0.,FALSE, 5.090581e-10,12.49915, 0.) as CO2KalmanC;
  CO2FilterWrapper.Filter -> CO2KalmanC;
  CO2Detector -> CO2KalmanC.Predict;
#endif
#ifdef DEWMA
  components new DEWMAC(0., 0., FALSE, SIP_CO2_ALPHA, SIP_CO2_BETA) as CO2DEWMAC; 
  CO2FilterWrapper.Filter -> CO2DEWMAC;
  CO2Detector -> CO2DEWMAC.Predict; 
#endif

  CO2FilterWrapper.GetSensorValue -> AirQualityM.ReadCO2;
  CO2FilterWrapper.LocalTime -> HilTimerMilliC;
  CO2Detector.FilterRead -> CO2FilterWrapper.Read;

  //AQ  
  components new FilterM() as AQFilterWrapper;
  components new EventDetectorC(SIP_AQ_THRESH) as AQDetector; 
#ifdef KALMAN
  components new KalmanC(0.,0.,FALSE, 7.276443e-16, 0.003926976 , 0.) as AQKalmanC;
  AQFilterWrapper.Filter -> AQKalmanC;
  AQDetector -> AQKalmanC.Predict;
#endif
#ifdef DEWMA
  components new DEWMAC(0., 0., FALSE, SIP_AQ_ALPHA, SIP_AQ_BETA) as AQDEWMAC; 
  AQFilterWrapper.Filter -> CO2DEWMAC;
  AQDetector -> AQDEWMAC.Predict; 
#endif

  AQFilterWrapper.GetSensorValue -> AirQualityM.ReadAQ;
  AQFilterWrapper.LocalTime -> HilTimerMilliC;
  AQDetector.FilterRead -> AQFilterWrapper.Read;
  
  //VOC
  components new FilterM() as VOCFilterWrapper;
  components new EventDetectorC(SIP_VOC_THRESH) as VOCDetector; 
#ifdef KALMAN
  components new KalmanC(0.,0.,FALSE, 7.276443e-16, 0.003926976 , 0.) as VOCKalmanC;
  VOCFilterWrapper.Filter -> VOCKalmanC;
  VOCDetector -> VOCKalmanC.Predict;
#endif
#ifdef DEWMA
  components new DEWMAC(0., 0., FALSE, SIP_VOC_ALPHA, SIP_VOC_BETA) as VOCDEWMAC; 
  VOCFilterWrapper.Filter -> VOCDEWMAC;
  VOCDetector -> VOCDEWMAC.Predict; 
#endif

  VOCFilterWrapper.GetSensorValue -> AirQualityM.ReadVOC;
  VOCFilterWrapper.LocalTime -> HilTimerMilliC;
  VOCDetector.FilterRead -> VOCFilterWrapper.Read;


  components new FilterM() as VoltageFilterWrapper;
  components new EventDetectorC(0.01) as VoltageDetector;
#ifdef KALMAN
  components new KalmanC(0.,0.,FALSE, 1.032982e-19,8.268842e-6, 0.) as VoltageKalmanC;
  VoltageFilterWrapper.Filter -> VoltageKalmanC;
  VoltageDetector -> VoltageKalmanC.Predict;
#endif
#ifdef DEWMA
  components new DEWMAC(0., 0., FALSE, 0.001, 0.01) as VoltageDEWMAC;
  VoltageFilterWrapper.Filter -> VoltageDEWMAC;
  VoltageDetector -> VoltageDEWMAC.Predict;
#endif

  VoltageFilterWrapper.GetSensorValue -> BatterySensingM.ReadBattery;
  VoltageFilterWrapper.LocalTime -> HilTimerMilliC;
  VoltageDetector.FilterRead -> VoltageFilterWrapper.Read;

  //Add in the event detecors
  
  //link modules to main file
  CogentHouseP.ReadTemp -> TempDetector.Read;
  CogentHouseP.TempTrans -> TempDetector.TransmissionControl;
  CogentHouseP.ReadHum -> HumDetector.Read;
  CogentHouseP.HumTrans -> HumDetector.TransmissionControl;
  CogentHouseP.ReadVolt -> VoltageDetector.Read;
  CogentHouseP.VoltTrans -> VoltageDetector.TransmissionControl;
  CogentHouseP.ReadCO2 -> CO2Detector.Read;
  CogentHouseP.CO2Trans -> CO2Detector.TransmissionControl;
  
  CogentHouseP.ReadAQ -> AQDetector.Read;
  CogentHouseP.AQTrans -> AQDetector.TransmissionControl;
  
  CogentHouseP.ReadVOC -> VOCDetector.Read;
  CogentHouseP.VOCTrans -> VOCDetector.TransmissionControl;



  components HilTimerMilliC;
	
  CogentHouseP.LocalTime -> HilTimerMilliC;
  
  //Configured
  //Need to define right size
  components new AccessibleBitVectorC(RS_SIZE) as Configured;
  CogentHouseP.Configured -> Configured.AccessibleBitVector;

  //expectReadDone
  components new BitVectorC(RS_SIZE) as ExpectReadDone;
  CogentHouseP.ExpectReadDone -> ExpectReadDone.BitVector;


  //PackState
  components new PackStateC(SC_SIZE) as PackState;
  components new AccessibleBitVectorC(SC_SIZE) as ABV;

  PackState.Mask -> ABV;
  CogentHouseP.PackState -> PackState;

}