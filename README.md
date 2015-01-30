## Developer Cloud Sandbox interferogram processing with ADORE DORIS 

The Delft Institute of Earth Observation and Space Systems of Delft University of Technology has developed an Interferometric Synthetic Aperture Radar (InSAR) processor named [Doris](http://doris.tudelft.nl/) (Delft object-oriented radar interferometric software)

Doris is a standalone program that can perform most common steps of the interferometric radar processing in a modular set up. Doris handles SLC (Single Look Complex) data to generate interferometric products, and can be used to georeference unwrapped products.

ADORE stands for [Automated DORIS Environment](https://code.google.com/p/adore-doris/). It is development started at the University of Miami Geodesy Group, to help researchers generate interferograms with ease. Just like DORIS it is an open source project and it comes with the same license. ADORE tries to provide a streamlined user interface for generating interferograms with DORIS and has some additional features for displaying and exporting the results, and time series analysis. 

## Quick link
 
* [Getting Started](#getting-started)
* [Installation](#installation)
* [Submitting the workflow](#submit)
* [Community and Documentation](#community)
* [Authors](#authors)
* [Questions, bugs, and suggestions](#questions)
* [License](#license)

### <a name="getting-started"></a>Getting Started 

To run this application you will need a Developer Cloud Sandbox, that can be either requested from:
* ESA [Geohazards Exploitation Platform](https://geohazards-tep.eo.esa.int) for GEP early adopters;
* ESA [Research & Service Support Portal](http://eogrid.esrin.esa.int/cloudtoolbox/) for ESA G-POD related projects and ESA registered user accounts
* From [Terradue's Portal](http://www.terradue.com/partners), provided user registration approval. 

A Developer Cloud Sandbox provides Earth Sciences data access services, and helper tools for a user to implement, test and validate a scalable data processing application. It offers a dedicated virtual machine and a Cloud Computing environment.
The virtual machine runs in two different lifecycle modes: Sandbox mode and Cluster mode. 
Used in Sandbox mode (single virtual machine), it supports cluster simulation and user assistance functions in building the distributed application.
Used in Cluster mode (a set of master and slave nodes), it supports the deployment and execution of the application with the power of distributed computing for data processing over large datasets (leveraging the Hadoop Streaming MapReduce technology). 
### <a name="installation"></a>Installation

#### Pre-requisites

Downgrade *geos* and install python-lxml:

```bash
sudo yum -y downgrade geos-3.3.2
sudo yum -y install python-lxml
sudo yum -y install snaphu
sudo yum -y install sar-helpers
```

##### Using the releases

Log on the developer cloud sandbox. Download the rpm package from https://github.com/Terradue/dcs-doris-l1-coseismic/releases. 
Install the dowanloaded package by running these commands in a shell:

```bash
sudo yum -y install dcs-doris-ifg-<version>-ciop.x86_64.rpm
```

#### Using the development version

Log on the developer sandbox and run these commands in a shell:

```bash
sudo yum -y install adore-t2
cd
git clone git@github.com:geohazards-tep/dcs-doris-ifg.git
cd dcs-doris-ifg
mvn install
```

### <a name="submit"></a>Submitting the workflow

Run this command in a shell:

```bash
ciop-run
```
Or invoke the Web Processing Service via the Sandbox dashboard or the [Geohazards Thematic Exploitation platform](https://geohazards-tep.eo.esa.int) providing a master/slave product URL and optionally:

* A set Doris input cards values separated by comma e.g.:
```
m_dbow_geo="37.755 14.995 12200 12200",rs_dbow_geo="37.755 14.995 12000 12000",cc_winsize="128 128",fc_acc="8 8",int_multilook="1 1",coh_multilook="1 1",dumpbaseline="15 10"
```
* A point of interest in WKT format e.g.: *POINT(13.4 42.35)*
* An extent in pixels for a region around the point of interests e.g.: *2000,2000*

### <a name="community"></a>Community and Documentation

To learn more and find information go to 

* [Developer Cloud Sandbox](http://docs.terradue.com/developer) service 
* [Doris](http://doris.tudelft.nl/)
* [Adore Doris](https://code.google.com/p/adore-doris/)
* [ESA Geohazards Exploitation Platform](https://geohazards-tep.eo.esa.int)
* [DLR Supersite TerraSAR-X](https://supersites.eoc.dlr.de/)

### <a name="authors"></a>Authors (alphabetically)

* Brito Fabrice
* D'Andria Fabio

### <a name="questions"></a>Questions, bugs, and suggestions

Please file any bugs or questions as [issues](https://github.com/geohazards-tep/dcs-doris-ifg/issues/new) or send in a pull request.

### <a name="license"></a>License

Copyright 2015 Terradue Srl

Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0

> This work has been co-funded by the EC FP7 project MED-SUV Grant agreement 308665 
