PFLAGS += -I . \
	-I %T/lib/net \
	-I %T/lib/net/ctp \
	-I %T/lib/net/drip \
	-I %T/lib/printf \
	-I ../Util  \
	-I ../Util/HashMap  \
	-I ./AccessibleBitVector \
	-I ./EventDetector \
	-I ./FilterWrapper \
	-I ./Filters/ \
	-I ./Filters/DEWMA \
	-I ./Filters/PassThrough  \
	-I ./Heartbeat \
	-I ./PackState \
	-I ./Predict \
	-I ./SIPController  \
	-I ./Sensing/ACStatus \
	-I ./Sensing/AirQuality \
	-I ./Sensing/Base \
	-I ./Sensing/BlackBulb \
	-I ./Sensing/CurrentCost  \
	-I ./Sensing/PulseReader  \
	-I ./Sensing/TempADC \
        -I ./Sensing/WallSensors \
	-I ./Sensing/WindowStatus 

# use "make telosb install.2 cluster_based=1" to turn on cluster-based code

ifdef cluster_based
PFLAGS += -I ../Util/ch4bitle
BUILD_EXTRA_DEPS += ../Util/ch4bitle/LinkEstimatorP.nc
CFLAGS += -DCLUSTER_BASED
else #lpl based
PFLAGS += -I %T/lib/net/4bitle
CFLAGS += -DLOW_POWER_LISTENING
CFLAGS += -DLPL_DEF_LOCAL_WAKEUP=1024
CFLAGS += -DLPL_DEF_REMOTE_WAKEUP=1024
CFLAGS += -DDELAY_AFTER_RECEIVE=20
endif

COMPONENT=CogentHouseC

PYTHON_TARGET_DIR=../../cogent/node
PYTHON_TGTS=$(addprefix $(PYTHON_TARGET_DIR)/,StateMsg.py BootMsg.py ConfigMsg.py Packets.py AckMsg.py)
BUILD_EXTRA_DEPS += $(PYTHON_TGTS)
CLEAN_EXTRA += $(PYTHON_TGTS)

#Configuration
# turn on leds for debugging?
# use "make telosb install.2 debug=1" to turn on debug
ifdef debug
CFLAGS += -DBLINKY
CFLAGS += -DDEBUG
endif

# if ac-powered node does not have ac-sensor but should still act as a
# cluster-head use "make ... missing_ac_sensor=1"
ifdef missing_ac_sensor
CFLAGS += -DMISSING_AC_SENSOR
endif

# radio channel
# use "make ... rf_channel=19" to get a radio channel of 19
ifdef rf_channel
CFLAGS += -DCC2420_DEF_CHANNEL=$(rf_channel)
endif

REVISION=$(shell hg id -i)
CFLAGS+=-DDEF_HG_REVISION="\"$(REVISION)\""

PFLAGS +=-DTOSH_DATA_LENGTH=76

CFLAGS += -DHEARTBEAT_MULTIPLIER=7L #7 hours SIP 
CFLAGS += -DHEARTBEAT_PERIOD=3686400L #3686400L #1 hour  88473600 #1 day

# default sensing period 307200 = 5 mins
CFLAGS += -DDEF_FIRST_PERIOD=10240
CFLAGS += -DDEF_SENSE_PERIOD=307200L
CFLAGS += -DDEF_BACKOFF_SENSE_PERIOD=307200L
CFLAGS += -DLEAF_TIMEOUT_TIME=10240L
CFLAGS += -DLOW_VOLTAGE=2.35

CFLAGS += -DDEWMA
CFLAGS += -DSIP_TEMP_MASK=1
CFLAGS += -DSIP_TEMP_THRESH=0.5
CFLAGS += -DSIP_TEMP_ALPHA=0.2
CFLAGS += -DSIP_TEMP_BETA=0.2

CFLAGS += -DSIP_TEMPADC_MASK=1
CFLAGS += -DSIP_TEMPADC_THRESH=0.5
CFLAGS += -DSIP_TEMPADC_ALPHA=0.2
CFLAGS += -DSIP_TEMPADC_BETA=0.2

CFLAGS += -DSIP_HUM_MASK=1
CFLAGS += -DSIP_HUM_THRESH=2.
CFLAGS += -DSIP_HUM_ALPHA=0.2
CFLAGS += -DSIP_HUM_BETA=0.2

CFLAGS += -DSIP_BATTERY_MASK=1
CFLAGS += -DSIP_BATTERY_THRESH=0.1
CFLAGS += -DSIP_BATTERY_ALPHA=0.05
CFLAGS += -DSIP_BATTERY_BETA=0.1

CFLAGS += -DSIP_CO2_MASK=1
CFLAGS += -DSIP_CO2_THRESH=100.
CFLAGS += -DSIP_CO2_ALPHA=0.2
CFLAGS += -DSIP_CO2_BETA=0.2

CFLAGS += -DSIP_BB_MASK=1
CFLAGS += -DSIP_BB_THRESH=0.0025
CFLAGS += -DSIP_BB_ALPHA=0.2
CFLAGS += -DSIP_BB_BETA=0.2

CFLAGS += -DSIP_AQ_MASK=1
CFLAGS += -DSIP_AQ_THRESH=0.1
CFLAGS += -DSIP_AQ_ALPHA=0.05
CFLAGS += -DSIP_AQ_BETA=0.05

CFLAGS += -DSIP_VOC_MASK=1
CFLAGS += -DSIP_VOC_THRESH=100.
CFLAGS += -DSIP_VOC_ALPHA=0.05
CFLAGS += -DSIP_VOC_BETA=0.05

CFLAGS += -DSIP_OPTI_MASK=1
CFLAGS += -DSIP_OPTI_THRESH=1000 # units are 0.001 kWh
CFLAGS += -DSIP_OPTI_ALPHA=0.2
CFLAGS += -DSIP_OPTI_BETA=0.2

CFLAGS += -DSIP_CC_MASK=1
CFLAGS += -DSIP_CC_THRESH=50
CFLAGS += -DSIP_CC_ALPHA=0
CFLAGS += -DSIP_CC_BETA=0

CFLAGS += -DSIP_GAS_MASK=1
CFLAGS += -DSIP_GAS_THRESH=100
CFLAGS += -DSIP_GAS_ALPHA=0
CFLAGS += -DSIP_GAS_BETA=0

CFLAGS += -DSIP_HME_MASK=1
CFLAGS += -DSIP_HME_THRESH=1
CFLAGS += -DSIP_HME_ALPHA=0
CFLAGS += -DSIP_HME_BETA=0

CFLAGS += -DSIP_HMV_MASK=1
CFLAGS += -DSIP_HMV_THRESH=1
CFLAGS += -DSIP_HMV_ALPHA=0
CFLAGS += -DSIP_HMV_BETA=0

CFLAGS += -DSIP_WINDOW_MASK=1
CFLAGS += -DSIP_WINDOW_THRESH=1
CFLAGS += -DSIP_WINDOW_ALPHA=0
CFLAGS += -DSIP_WINDOW_BETA=0


CFLAGS += -DSIP_WALL_TEMP_MASK=1
CFLAGS += -DSIP_WALL_TEMP_THRESH=-1
CFLAGS += -DSIP_WALL_TEMP_ALPHA=0
CFLAGS += -DSIP_WALL_TEMP_BETA=0

CFLAGS += -DSIP_WALL_HUM_MASK=1
CFLAGS += -DSIP_WALL_HUM_THRESH=-1
CFLAGS += -DSIP_WALL_HUM_ALPHA=0
CFLAGS += -DSIP_WALL_HUM_BETA=0

include $(MAKERULES)

$(PYTHON_TARGET_DIR)/StateMsg.py: ../Packets.h
	mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=$(notdir $(basename $@)) $< StateMsg -o $@

$(PYTHON_TARGET_DIR)/BootMsg.py: ../Packets.h
	mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=$(notdir $(basename $@)) $< BootMsg -o $@

$(PYTHON_TARGET_DIR)/ConfigMsg.py: ../Packets.h
	mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=$(notdir $(basename $@)) $< ConfigMsg -o $@

$(PYTHON_TARGET_DIR)/AckMsg.py: ../Packets.h
	mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=$(notdir $(basename $@)) $< AckMsg -o $@

$(PYTHON_TARGET_DIR)/Packets.py: ../Packets.h PackState/packstate.h
	ncg python -target=$(PLATFORM) $(CFLAGS) -python-classname=$(notdir $(basename $@)) $< Packets.h -o $@

../Util/ch4bitle/LinkEstimatorP.nc: ../Util/ch4bitle.patch
	-rm -rf ../Util/ch4bitle
	cp -r $(TOSROOT)/tos/lib/net/4bitle ../Util/ch4bitle
	(cd ../Util/ch4bitle/ && patch -p0) < $<
