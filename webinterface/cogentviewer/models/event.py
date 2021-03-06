"""
Classes and Modules that represent events wthihn thte datastream

.. codeauthor::  Ross Wiklins 
.. codeauthor::  James Brusey
.. codeauthor::  Daniel Goldsmith <djgoldsmith@googlemail.com>
"""

import meta

from sqlalchemy import Column, Integer, String, ForeignKey, DateTime

class Event(meta.Base, meta.InnoDBMix):
    """
    Class to represent Events,


    :var Integer id: Id of Event
    :var int houseId: Id of House that this event occorued at.
    :var String name: Name of Event
    :var String description: Optional Description
    :var DateTime time: Time Event occoured

    """
    __tablename__ = "Event"

    id = Column(Integer, primary_key=True)
    houseId = Column(Integer, ForeignKey('House.id'))
    name = Column(String(50))
    description = Column(String(255), nullable=True)
    time = Column(DateTime)

    def __str__(self):
        return "{0} {1} {2} {3}".format(self.id,
                                        self.houseId,
                                        self.name,
                                        self.time)
