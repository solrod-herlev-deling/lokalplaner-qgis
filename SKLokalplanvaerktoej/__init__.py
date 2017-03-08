# -*- coding: utf-8 -*-
"""
/***************************************************************************
 SKLokalplanvaerktoej
                                 A QGIS plugin
 Panel til at arbejdet med lokalplaner
                             -------------------
        begin                : 2016-07-28
        copyright            : (C) 2016 by Rasmus Slot/Solrød Kommune
        email                : rsp@solrod.dk
        git sha              : $Format:%H$
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
 This script initializes the plugin, making it known to QGIS.
"""


# noinspection PyPep8Naming
def classFactory(iface):  # pylint: disable=invalid-name
    """Load SKLokalplanvaerktoej class from file SKLokalplanvaerktoej.

    :param iface: A QGIS interface instance.
    :type iface: QgsInterface
    """
    #
    from .SKLokalplanvaerktoej import SKLokalplanvaerktoej
    return SKLokalplanvaerktoej(iface)
