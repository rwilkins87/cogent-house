/* AirQualityM.nc - Methods to sample both CO2 and VOC sensors

   Copyright (C) 2011 Ross Wilkins

   This File is part of Cogent-House

   Cogent-House is free software: you can redistribute it and/or
   modify it under the terms of the GNU General Public License as
   published by the Free Software Foundation, either version 3 of the
   License, or (at your option) any later version.

   Cogent-House is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program. If not, see
   <http://www.gnu.org/licenses/>.



===================
Air Quality Module
===================

AirQualityM provides methods ReadCO2 and ReadVOC to sample both CO2 and 
VOC on ADC channels. This sampled value is then converted into a real PPM 
engineering value and returned.


:author: Ross Wilkins
:email: ross.wilkins87@googlemail.com
:date:  6th January 2011
*/





module AirQualityM
{
	provides 
	{
		interface Read<float> as ReadCO2;
		interface Read<float> as ReadVOC;
		interface Read<float> as ReadAQ;
	}
	uses
	{		
		interface Read<uint16_t> as GetCO2;
		interface Read<uint16_t> as GetVOC;
		interface Read<uint16_t> as GetAQ;
		interface HplMsp430GeneralIO as CO2On;
		interface Timer<TMilli> as WarmUpTimer;
	}
}
implementation
{

	const uint32_t DELAY_PERIOD=10240;
	const float vref=3.3;
	const float maxAdc=4096.0;
	float co2Coeffs[] = {-1250, 5000};
	float vocCoeffs[] = {450, 620};


	task void readCO2Task()
	{
		//enable sensor - turn on GPIO2
		call CO2On.makeOutput();
		call CO2On.set();
		//let the sensor warmup
		call WarmUpTimer.startOneShot(DELAY_PERIOD);
	}

	event void WarmUpTimer.fired() {
		call GetCO2.read();
	}

	task void readVOCTask()
	{
		call GetVOC.read();
	}

	task void readAQTask()
	{
		call GetAQ.read();
	}

	command error_t ReadCO2.read()
	{
		post readCO2Task();
		return SUCCESS;
	}

	command error_t ReadVOC.read()
	{
		post readVOCTask();
		return SUCCESS;
	}

	command error_t ReadAQ.read()
	{
		post readAQTask();
		return SUCCESS;
	}


	#ifdef DEBUG
	void printfFloat(float toBePrinted) {
		uint32_t fi, f0, f1, f2;
		char c;
		float f = toBePrinted;

		if (f<0){
			c = '-'; f = -f;
		} else {
			c = ' ';
		}

		// integer portion.
		fi = (uint32_t) f;

		// decimal portion...get index for up to 3 decimal places.
		f = f - ((float) fi);
		f0 = f*10;   f0 %= 10;
		f1 = f*100;  f1 %= 10;
		f2 = f*1000; f2 %= 10;
		printf("%c%ld.%d%d%d\n", c, fi, (uint8_t) f0, (uint8_t) f1, (uint8_t) f2);
	}
	#endif

	//Convert raw adc to temp
	event void GetCO2.readDone(error_t result, uint16_t data) {
		float voltage;
		float CO2;
		call CO2On.clr();
		voltage=(data/maxAdc)*vref;
		#ifdef DEBUG
		printf("Co2 voltage: ");
		printfFloat(voltage);
		printf("\n");
		printfflush();
		#endif
		CO2 = horner(sizeof(co2Coeffs)/sizeof(float)-1, co2Coeffs, (float)voltage);
		signal ReadCO2.readDone(SUCCESS, CO2);
	}

	//Convert raw adc to temp
	event void GetVOC.readDone(error_t result, uint16_t data) {	
		float voltage;
		float voc;
		voltage=(data/maxAdc)*vref;
		#ifdef DEBUG
		printf("VOC voltage: ");
		printf("%u",data);
		printfFloat(voltage);
		printf("\n");
		printfflush();
		#endif
		voc = horner(sizeof(vocCoeffs)/sizeof(float)-1, vocCoeffs, (float)voltage);
		signal ReadVOC.readDone(SUCCESS, voc);
	}

	//Convert raw adc to temp
	event void GetAQ.readDone(error_t result, uint16_t data) {
		float AQV;
		AQV=(data/maxAdc)*vref;
		#ifdef DEBUG
		printf("AQ voltage: ");
		printfFloat(AQV);
		printf("\n");
		printfflush();
		#endif
		signal ReadAQ.readDone(SUCCESS, AQV);
	}


}
