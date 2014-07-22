
#from datetime import datetime
import datetime

import cogentviewer.models as models
import cogentviewer.tests.base as base

NOW = datetime.datetime.now()

class TestReading(base.ModelTestCase):

    def _serialobj(self):
        """Helper Method to provde an object to serialise"""
        theItem = models.Reading(time = NOW,
                                 nodeId = 1,
                                 typeId = 2,
                                 locationId = 3,
                                 value = 45.0)
        return theItem

    def _dictobj(self):
        """Helper method to provide a dictionay representaiton of the object
        generated by _serialobj()"""


        #REMEMEBR THAT Reading does some name trickery
        theDict = {"__table__" : "Reading",
                   "time" : NOW.isoformat(),
                   "nodeId" : 1,
                   "type" : 2,
                   "locationId" : 3,
                   "value" : 45.0}
        return theDict

    def testAdict(self):
        #Dictionary Conversion
        foo = self._serialobj()
        bar = self._dictobj()
        foo = foo.dict()
        self.assertEqual(foo,bar)

    def testEq(self):
        #"""Test for Equality"""
        item1 = models.Reading(time = NOW,
                               nodeId = 1,
                               typeId = 2,
                               locationId = 3,
                               value = 45.0)

        item2 = models.Reading(time = NOW,
                               nodeId = 1,
                               typeId = 2,
                               locationId = 3,
                               value = 45.0)



        self.assertEqual(item1, item2)
        self.assertReallyEqual(item1, item2)


        #Or Location id
        item2.locationId = 10
        self.assertReallyEqual(item1, item2)



    def testNEQ(self):
        #"""Test for Inequality"""
        item1 = models.Reading(time = NOW,
                               nodeId = 1,
                               typeId = 2,
                               locationId = 3,
                               value = 45.0)

        item2 = models.Reading(time = NOW,
                               nodeId = 1,
                               typeId = 2,
                               locationId = 3,
                               value = 45.0)

        self.assertEqual(item1, item2)

        item2.time = datetime.datetime.now()
        self.assertReallyNotEqual(item1, item2)

        item2.time = item1.time
        item2.nodeId = 10
        self.assertReallyNotEqual(item1, item2)

        item2.nodeId = 1
        item2.typeId = 10
        self.assertReallyNotEqual(item1, item2)

        item2.locationId = 3
        item2.value = 0.0
        self.assertReallyNotEqual(item1, item2)

    def testCmp(self):
    #     """Test Compaison function
    #     (actually __lt__ for Py3K Comat)"""

        item1 = models.Reading(time = NOW,
                               nodeId = 1,
                               typeId = 2,
                               locationId = 3,
                               value = 45.0)

        item2 = models.Reading(time = NOW,
                               nodeId = 1,
                               typeId = 2,
                               locationId = 3,
                               value = 45.0)

        self.assertEqual(item1, item2)

        item2.time = datetime.datetime.now()
        self.assertGreater(item2, item1)
