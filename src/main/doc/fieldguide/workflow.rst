Workflow design
===============

Data
****

You will use the Envisat ASAR Image Mode Single Look Complex (ASA_IMS_1P) datasets over L'Aquila made available by `ESA <http://www.esa.int/>`_ on the Eo Virtual Archive 4 `<http://eo-virtual-archive4.esa.int/>`_

The list of datasets used as test data is:

* ASA_IMS_1PNDPA20070411_204750_000000162057_00129_26736_3123.N1

  Relative orbit 129, acquired April 4th, 2007 (532 MB) - used as slave 

* ASA_IMS_1PNDPA20080326_204749_000000162067_00129_31746_3124.N1

  Relative orbit 129, acquired March 26th, 2008 (532 MB) - used as slave
  
* ASA_IMS_1PNDPA20090311_204746_000000162077_00129_36756_3125.N1

  Relative orbit 129, acquired March 11th, 2009 (532 MB) - Scene acquired after the L'Aquila earthquake of April 6th 2009 and used as master

Software and COTS
*****************

Doris and Adore
---------------

You will use Adore[#f1]_,  set of bash scripts to ease use of TU-DELFT's DORIS software [#f2]_.

The Delft Institute of Earth Observation and Space Systems of Delft University of Technology has developed an Interferometric Synthetic Aperture Radar (InSAR) processor named Doris (Delft object-oriented radar interferometric software).

Doris is invoked using ADORE - Automated Doris Environment. Its development started at the University of Miami Geodesy Group, to help researchers generate interferograms with ease. Just like Doris it is an open source project and it comes with the same license. ADORE tries to provide a streamlined user interface for generating interferograms with DORIS and has some additional features for displaying and exporting the results, and time series analysis. 

Workflow design
***************

The application's data pipeline activities can be defined as follows:

Use Adore (and Doris) to create two co-seismic interferograms sharing the same master.

.. uml::

  !define DIAG_NAME Workflow example

  !include includes/skins.iuml

  skinparam backgroundColor #FFFFFF
  skinparam componentStyle uml2

  start
  
  :Stage-in master;
  :Detect master mission;
  :Create Environment;
  
  while (check stdin?) is (line)
    :Stage-in slave;
    :Apply Adore script;
    :Stage-out interferogram;
    :Stage-out images;
    :Stage-out logs;
  endwhile (empty)

  stop

This translates into a very simple workflow containing a single processing step: node_adore

The simple workflow can be represented as:

.. uml::

  !define DIAG_NAME Workflow example

  !include includes/skins.iuml

  skinparam backgroundColor #FFFFFF
  skinparam componentStyle uml2

  start

  :node_adore;
  
  stop

The *node_adore* is described in details in :doc:`dcs-doris-ifg/src/main/doc/fieldguide/nodes/index`

.. [#f1] `Adore-doris Automated DORIS Environment (adore) is a set of bash scripts to ease use of TU-DELFT's DORIS software<https://code.google.com/p/adore-doris/>`_

.. [#f2] `DORIS Delft object-oriented radar interferometric software <http://doris.tudelft.nl/>`_
