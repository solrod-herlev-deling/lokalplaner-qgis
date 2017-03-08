# -*- coding: utf-8 -*-
"""
/***************************************************************************
 SKLokalplanvaerktøj
                                 A QGIS plugin
 Panel til at arbejdet med lokalplaner
                              -------------------
        begin                : 2016-07-28
        git sha              : $Format:%H$
        copyright            : (C) 2016 by Rasmus Slot/Solrød Kommune
        email                : rsp@solrod.dk
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

"""
from PyQt4.QtCore import QSettings, QTranslator, qVersion, QCoreApplication, Qt
from PyQt4.QtGui import QAction, QIcon, QMessageBox

from qgis.core import *
from qgis.utils import iface

# Import the code for the DockWidget
from SKLokalplanvaerktoej_dockwidget import SKLokalplanvaerktoejDockWidget
import os.path
import resources

class SKLokalplanvaerktoej:
    """QGIS Plugin Implementation."""

    def __init__(self, iface):
        """Constructor.

        :param iface: An interface instance that will be passed to this class
            which provides the hook by which you can manipulate the QGIS
            application at run time.
        :type iface: QgsInterface
        """
        # Save reference to the QGIS interface
        self.iface = iface

        # initialize plugin directory
        self.plugin_dir = os.path.dirname(__file__)

        # initialize locale
        locale = QSettings().value('locale/userLocale')[0:2]
        locale_path = os.path.join(
            self.plugin_dir,
            'i18n',
            'SKLokalplanvaerktoej_{}.qm'.format(locale))

        if os.path.exists(locale_path):
            self.translator = QTranslator()
            self.translator.load(locale_path)

            if qVersion() > '4.3.3':
                QCoreApplication.installTranslator(self.translator)

        # Declare instance attributes
        self.actions = []
        self.menu = self.tr(u'SKLokalplanvaerktoej')
        # todo: We are going to let the user set this up in a future iteration
        self.toolbar = self.iface.addToolBar(u'SKLokalplanvaerktoej')
        self.toolbar.setObjectName(u'SKLokalplanvaerktoej')

        #print "** INITIALIZING SKLokalplanvaerktoej"

        self.pluginIsActive = False
        self.dockwidget = None


    # noinspection PyMethodMayBeStatic
    def tr(self, message):
        """Get the translation for a string using Qt translation API.

        We implement this ourselves since we do not inherit QObject.

        :param message: String for translation.
        :type message: str, QString

        :returns: Translated version of message.
        :rtype: QString
        """
        # noinspection PyTypeChecker,PyArgumentList,PyCallByClass
        return QCoreApplication.translate('SKLokalplanvaerktoej', message)


    def add_action(
        self,
        icon_path,
        text,
        callback,
        enabled_flag=True,
        add_to_menu=True,
        add_to_toolbar=True,
        status_tip=None,
        whats_this=None,
        parent=None):
        """Add a toolbar icon to the toolbar.

        :param icon_path: Path to the icon for this action. Can be a resource
            path (e.g. ':/plugins/foo/bar.png') or a normal file system path.
        :type icon_path: str

        :param text: Text that should be shown in menu items for this action.
        :type text: str

        :param callback: Function to be called when the action is triggered.
        :type callback: function

        :param enabled_flag: A flag indicating if the action should be enabled
            by default. Defaults to True.
        :type enabled_flag: bool

        :param add_to_menu: Flag indicating whether the action should also
            be added to the menu. Defaults to True.
        :type add_to_menu: bool

        :param add_to_toolbar: Flag indicating whether the action should also
            be added to the toolbar. Defaults to True.
        :type add_to_toolbar: bool

        :param status_tip: Optional text to show in a popup when mouse pointer
            hovers over the action.
        :type status_tip: str

        :param parent: Parent widget for the new action. Defaults None.
        :type parent: QWidget

        :param whats_this: Optional text to show in the status bar when the
            mouse pointer hovers over the action.

        :returns: The action that was created. Note that the action is also
            added to self.actions list.
        :rtype: QAction
        """

        icon = QIcon(icon_path)
        action = QAction(icon, text, parent)
        action.triggered.connect(callback)
        action.setEnabled(enabled_flag)

        if status_tip is not None:
            action.setStatusTip(status_tip)

        if whats_this is not None:
            action.setWhatsThis(whats_this)

        if add_to_toolbar:
            self.toolbar.addAction(action)

        if add_to_menu:
            self.iface.addPluginToMenu(
                self.menu,
                action)

        self.actions.append(action)

        return action


    def initGui(self):
        """Create the menu entries and toolbar icons inside the QGIS GUI."""

        icon_path = ':/plugins/SKLokalplanvaerktoej/icon.png'
        self.add_action(
            icon_path,
            text=self.tr(u''),
            callback=self.run,
            parent=self.iface.mainWindow())

    #--------------------------------------------------------------------------

    def onClosePlugin(self):
        """Cleanup necessary items here when plugin dockwidget is closed"""

        #print "** CLOSING SKLokalplanvaerktoej"

        # disconnects
        self.dockwidget.closingPlugin.disconnect(self.onClosePlugin)

        # remove this statement if dockwidget is to remain
        # for reuse if plugin is reopened
        # Commented next statement since it causes QGIS crashe
        # when closing the docked window:
        # self.dockwidget = None

        self.pluginIsActive = False


    def unload(self):
        """Removes the plugin menu item and icon from QGIS GUI."""

        #print "** UNLOAD SKLokalplanvaerktoej"

        for action in self.actions:
            self.iface.removePluginMenu(
                self.tr(u'SKLokalplanvaerktoej'),
                action)
            self.iface.removeToolBarIcon(action)
        # remove the toolbar
        del self.toolbar

    #--------------------------------------------------------------------------
    """
    ***************************************************************
    * Metoder til brug i pluginet:                                *
    ***************************************************************
    """
    #--------------------------------------------------------------------------
    
    
    #******************************************************
    #*  Returnerer view med lokalplaner - hvis ikke det   *
    #*  kan findes, vises en fejlmeddelelse               *
    #******************************************************    
    def getPlanlag(self):
        layerplans = QgsMapLayerRegistry.instance().mapLayersByName(u'v_lp_dropdown') 
        if layerplans:
            return layerplans[0]
        else:
            QMessageBox.critical(self.iface.mainWindow(),
                                 'Fejl',
                                 'Kan ikke finde lokalplaner')


    #******************************************************
    #*  Danner et dictionary med keys, der svarer til     *
    #*  menupunkterne i drop-down og id'er som values.    *
    #******************************************************    
    def makeplanlist(self, planlag):
        planliste = {}
        iter = planlag.getFeatures()
        for feature in iter:
            planliste.update({feature['plannr'] + ' ' + feature['plannavn']: feature['dropdown_id']})
        return planliste


    #******************************************************
    #*  Returnerer feature med lokalplanomraadet paa den  *
    #*  plan, der er valgt i Lokalplan-variablen.         * !
    #******************************************************    
    def getSelectedPlanFeature(self):
        planlag = self.getPlanlag()
        planliste = self.makeplanlist(planlag)
        planfeatures = planlag.getFeatures()
        for plan in planfeatures:
            if str(plan['dropdown_id']) == planliste[self.dockwidget.comboBox.currentText()]:
                return plan


    #******************************************************
    #*  Gentegn alle lag i kortet.                        *
    #******************************************************            
    def refresh_layers(self):
        for layer in self.iface.mapCanvas().layers():
            layer.triggerRepaint()


    #******************************************************
    #*  Hvis man vælger at filtrere skal filter slåes til *
    #*  og ellers skal det slåes fra.                     *
    #*  Denne funktion kaldes også, når en ny plan bliver *
    #*  valgt i drop-down listen.                         *
    #******************************************************    
    def checkbox(self, state):
        if state:
            for layer in self.getPlanlagMedFiltrering():
                layer.setSubsetString('')
            self.refresh_layers()
        else:
            planlag = self.getPlanlag()
            planliste = self.makeplanlist(planlag)
            if self.dockwidget.comboBox.currentText():
                for layer in self.getPlanlagMedFiltrering():
                    layer.setSubsetString(' "lp_id" = \'{0}\' '.format(planliste[self.dockwidget.comboBox.currentText()]))
            self.refresh_layers()


    #******************************************************
    #*  Efter valg af lokalplan i dropdown-listen skal    *
    #*  alle lag gentegnes med en ny filtrering.          *
    #******************************************************    
    def selectplan(self, state):
        self.checkbox(self.dockwidget.VisAllePlanerCheck.checkState())
        self.refresh_layers()


    #******************************************************
    #*  Toemmer comboboksen til valg af lokalplan, og     *
    #*  fylder den derefter med vaerdier fra tabellen med *
    #*  lokalplanomraader.Derefter saettes den til den    *
    #*  lokalplan, der allerede var i variablen Lokalplan * 
    #******************************************************
    def populateCombobox(self):
        planlag = self.getPlanlag()
        planliste = self.makeplanlist(planlag)
        
        #Teksten paa den plan, der er valgt foer comboboksen toemmes gemmes, saa planen kan findes igen, hvis den stadig er der.
        valgtplan = self.dockwidget.comboBox.currentText()
        
        for i in range(self.dockwidget.comboBox.count()):
            self.dockwidget.comboBox.removeItem(0)
        
        for plan in sorted(planliste.keys()):
            self.dockwidget.comboBox.addItem(plan)
        
        if valgtplan != u'': #Tjek at der overhovedet var valgt en plan (ikke tilfaeldet hvis pluginet lige er blevet indlaest)
            if self.dockwidget.comboBox.findText(valgtplan) != -1: # Tjek at den plan, der foer var valgt, stadig er i listen.
                self.dockwidget.comboBox.setCurrentIndex(self.dockwidget.comboBox.findText(valgtplan)) # Vaelg den tidligere valgte plan i listen.
        
        # Maaske boer det testes, hvordan den reagerer, hvis man sletter den valgte plan? Og eventuelt opdaterer listen?
    

    #***************************************************
    #*  Funktionen returnerer de lag som har et lp_id, *
    #*  som der skal filtreres på.                     *
    #***************************************************
    def getPlanlagMedFiltrering(self):
        
        layers = QgsMapLayerRegistry.instance().mapLayers()
        filterLayers = []

        # Gå igennem alle lag og tilføj dem til listen, hvis de har en lp_id-field
        for name, layer in layers.iteritems():
            if (layer.type() == QgsMapLayer.VectorLayer):
                for field in layer.fields():
                    if (field.name() == "lp_id"):
                        filterLayers.append(layer)
            
        return filterLayers

    #*************************************
    #*   Zoom kortet til hele kommunen   *
    #*************************************
    def extentToStart(self):
        canvas = iface.mapCanvas()
        rectangle = QgsRectangle(695257.51,6155979.01,705291.10,6162491.41) # Kommunens BBOX
        canvas.setExtent(rectangle)
        self.refresh_layers()
    
    #***************************************
    #*   Zoom kortet til den valgte plan   *
    #***************************************
    def extentToSelectedPlan(self):
        canvas = iface.mapCanvas()
        plan = self.getSelectedPlanFeature()
        canvas.setExtent(plan.geometry().boundingBox())
        self.refresh_layers()

    #---------------------------------------------------------------------------
    """
    **************************************************************
    * Selve run-metoden:                                         *
    **************************************************************
    """
    #---------------------------------------------------------------------------

    def run(self):
        """Run method that loads and starts the plugin"""

        if not self.pluginIsActive:
            self.pluginIsActive = True
			
            #print "** STARTING SKLokalplanvaerktoej"

            # dockwidget may not exist if:
            #    first run of plugin
            #    removed on close (see self.onClosePlugin method)
            if self.dockwidget == None:
                # Create the dockwidget (after translation) and keep reference
                self.dockwidget = SKLokalplanvaerktoejDockWidget()

            # connect to provide cleanup on closing of dockwidget
            self.dockwidget.closingPlugin.connect(self.onClosePlugin)

            # Tilfoej tooltips til widgets:
            self.dockwidget.refreshButton.setToolTip("Genopfrisk liste med lokalplaner!")
            
            # show the dockwidget
            # TODO: fix to allow choice of dock location
            self.iface.addDockWidget(Qt.TopDockWidgetArea, self.dockwidget)
            self.dockwidget.show()
            
            # Find lag med lokalplaner og giv fejlbesked, hvis det ikke lykkes:
            planlag = self.getPlanlag()
            
            # Der dannes et dictionary med lokalplanerne og comboBoxen udfyldes med valgmuligheder:
            self.populateCombobox()
            
            # Connect functions to signals from widgets:
            self.dockwidget.VisAllePlanerCheck.stateChanged.connect(self.checkbox)
            self.dockwidget.comboBox.activated.connect(self.selectplan)
            self.dockwidget.buttonZoomStart.clicked.connect(self.extentToStart)
            self.dockwidget.buttonZoomPlan.clicked.connect(self.extentToSelectedPlan)
            
            # Hvis der trykkes på genopfrisk-knappen, så skal comboBoxen opdateres.
            self.dockwidget.refreshButton.clicked.connect(self.populateCombobox)