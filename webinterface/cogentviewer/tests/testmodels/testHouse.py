
#from datetime import datetime
import datetime

#Python Module Imports
import sqlalchemy.exc


import json
import cogentviewer.models as models
import cogentviewer.tests.base as base

NOW = datetime.datetime.now()

class TestHouse(base.ModelTestCase):

    def _serialobj(self):
        """Helper Method to provde an object to serialise"""
        # rType = models.RoomType(id=1,
        #                         name="Test Type")

        theItem = models.House(id=1,
                               deploymentId =  1,
                               address = "10 Test Address",
                               startDate = NOW,
                               endDate = NOW,
                               )
        return theItem

    def _dictobj(self):
        """Helper method to provide a dictionay representaiton of the object
        generated by _serialobj()"""

        theDict = {"__table__":"House",
                   "id":1,
                   "deploymentId" :  1,
                   "address" : "10 Test Address",
                   "startDate" : NOW.isoformat(),
                   "endDate" : NOW.isoformat(),
                   }
        return theDict

    def testEq(self):
        """Test for Equality"""
        item1 = models.House(id=1,
                             deploymentId =  1,
                             address = "10 Test Address",
                             startDate = NOW,
                             endDate = NOW,
                             )

        item2 = models.House(id=1,
                             deploymentId =  1,
                             address = "10 Test Address",
                             startDate = NOW,
                             endDate = NOW,
                             )


        self.assertEqual(item1,item2)
        self.assertReallyEqual(item1,item2)

        #Id should not make any difference
        item2.id = 5
        self.assertEqual(item1,item2)
        self.assertReallyEqual(item1,item2)

    def testNEQ(self):
        
        item1 = models.House(id=1,
                             deploymentId =  1,
                             address = "10 Test Address",
                             startDate = NOW,
                             endDate = NOW,
                             )

        item2 = models.House(id=1,
                             deploymentId =  1,
                             address = "10 Test Address",
                             startDate = NOW,
                             endDate = NOW,
                             )


        self.assertEqual(item1,item2)

        #AGAIN,  Id and Deployment Id do not mater so much

        item2.address = "FOO"
        self.assertNotEqual(item1,item2)
        self.assertReallyNotEqual(item1,item2)

        item2.address = item1.address
        item2.startDate = datetime.datetime.now()

        self.assertNotEqual(item1,item2)
        self.assertReallyNotEqual(item1,item2)


    def testCmp(self):
        """Test Compaison function

        (actually __lt__ for Py3K Comat)"""
        
        item1 = models.House(id=1,
                             deploymentId =  1,
                             address = "10 Test Address",
                             startDate = NOW,
                             endDate = NOW,
                             )

        item2 = models.House(id=1,
                             deploymentId =  1,
                             address = "10 Test Address",
                             startDate = NOW,
                             endDate = NOW,
                             )

        
        self.assertEqual(item1,item2)
        
        #Order On Name
        item2.address = "1 Test"
        self.assertGreater(item1,item2)

        item2.address = "100 Test"
        self.assertLess(item1,item2)

        item2.address = item1.address
        item2.startDate = datetime.datetime.now()
        self.assertLess(item1,item2)

        item1.startDate = datetime.datetime.now()
        self.assertGreater(item1,item2)
