Node adore
==========

This is the first node of the workflow. As such, the platform takes cares of providing the inputs to the streaming executable: the list of Landsat catalogue entries you created earlier. 

.. tip:: ciop-copy can handle catalogue entries and download the datasets using the online resources in the metadata

A node requires a job template including:

* The path to the streaming executable:
* Default parameters
* Default configuration 

.. literalinclude:: ../../../app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 3-12

The job template for the job id *adore* defines three parameters:

----------------+-----------------+------------------------------------------------------------+
| Parameter name | Default value   | Description                                                | 
+==========+===========+============================================================+
| poi      | N/A       | Point of interest for the center of the interferogram.     |
|          |           | It is defined as a WKT point: POINT(lon lat)               |
|          |           | Example: POINT(13.4 42.35)                                 |
+----------+-----------+------------------------------------------------------------+
| extent   | 2000,2000 | Extent of the interferogram in Radar coordinates number of |
|          |           | pixels.                                                    |
+----------+-----------+------------------------------------------------------------+
| settings | N/A       | Comma separated list of name/values keys for fine-tuning   |
|          |           | the interferogram generation.                              |
|          |           | The list of settings is provided in [#f1]_ and [#f2]_      |
+----------+-----------+------------------------------------------------------------+
| master   | N/A       | Reference to the master file or catalogue entry            |
+----------+-----------+------------------------------------------------------------+

This information translates to:

.. literalinclude:: ../src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 6-32

While this job template doesn't define any parameter, it defines the *mapred.task.timeout* property which is the wall-time in miliseconds between two logging entries.

.. literalinclude:: ../src/src/main/app-resources/application.xml
  :language: xml
  :tab-width: 1
  :lines: 33-36

.. note::

  Log entries using ciop-log function in bash (or rciop.log in R and cioopy.log in Python) tell the platform the process is alive. If the wall-time is reached the execution is terminated with an error.

The streaming executable implements the activities:

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


The streaming executable source is available here: `/application/adore/run.sh <https://github.com/Terradue/dcs-doris-ifg/blob/master/src/main/app-resources/adore/run.sh>`_

  
.. [#f1] `Adore variables <https://code.google.com/p/adore-doris/wiki/adoreVariables>`_
.. [#f2] `Doris user manual <http://doris.tudelft.nl/usermanual/index.html>`_