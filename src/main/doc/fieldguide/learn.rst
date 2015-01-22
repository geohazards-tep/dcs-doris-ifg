What you will learn
===================

With this field guide application, you will learn:

1. To manage test data in a sandbox - you will copy Envisat ASAR Level 1 Image Mode data to the sandbox
2. To create an application invoking Doris to generate one or more interferograms 
3. To test the application - you will execute the node and workflow and inspect the results
4. To exploit the application - you will create the Web Processing Service (WPS) interface and invoke it; and invoke it via the Geohazards Exploitation platform

Where is the code
+++++++++++++++++

The code for this application is available on GitHub repository `dcs-doris-ifg <https://github.com/Terradue/dcs-doris-ifg>`_.

To deploy the application on a Developer Sandbox:

.. code-block:: console

  cd ~
  git clone https://github.com/Terradue/dcs-doris-ifg.git
  cd dcs-doris-ifg
  mvn install
  
This will build and deploy the application on the /application Developer Sandbox volume.

The code can be modified by forking the repository here: `<https://github.com/Terradue/dcs-doris-ifg/fork>`_

Before going further, install the dependencies:

.. code-block:: console

  sudo yum -y downgrade geos-3.3.2
  sudo yum install -y adore-t2 snaphu  

Questions, bugs, and suggestions
++++++++++++++++++++++++++++++++

Please file any questions, bugs or suggestions as `issues <https://github.com/Terradue/dcs-doris-ifg/issues/new>`_ or send us a pull request.
