#!/usr/bin/env python
# -*- encoding: utf-8 -*-
#
# Copyright (c) 2014 Jordi Mas i Hernandez <jmas@softcatala.org>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this program; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA.

import datetime


class Glossary:
    '''Represents a glossary'''

    def __init__(self):
        self.date = datetime.date.today().strftime("%d/%m/%Y")
        self.entries = []

    def get_dict(self):

        glossary_dict = {}
        entries = []

        for entry in self.entries:
            entries.append(entry.get_dict())

        glossary_dict['entries'] = entries
        glossary_dict['date'] = self.date
        return glossary_dict
