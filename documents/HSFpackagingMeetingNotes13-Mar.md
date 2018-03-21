---
title: "HSF Packaging Meeting #10, Mar 13 2016"
layout: default
---

# HSF Packaging Meeting #10, Mar 13 2016

[Indico Agenda](https://indico.cern.ch/event/518751/)

Present: Liz, Jim, Patrick, Lynn, Ben, Pere

## Introduction
The purpose of this meeting was to prepare for the hackathon at the May workshop.  It was recognised that we would need follow up work, but that the meeting would initiate that. 
We started the meeting by introducing the information that should be collected before the meeting and then presented by Patrick Gartung at the workshop.  The group agreed that we want the following answered:
* Where are we?
* What are the list of platforms Spack currently supports?

Patrick agrees to to create a table of Status by Platform for each Package that currently has Spack descriptions that we can count as done.  He published this to the google group after the meeting here: [Product-Matrix](https://github.com/HEP-SF/hep-spack/wiki/Product-Matrix)  
In order to come up with a comprehensive list of packages we’d like supported we agree to start from the LCGAA list and add intensity frontier packages.  Pere agreed to send a pointer to the list of packages that LCGAA supports.  That was also sent after the meeting here: [LCG-packages](http://lcgsoft.web.cern.ch/lcgsoft/release/84/ )  It is hoped that we can prioritize the work on those package descriptions to be done at the workshop via email exchanges on the list.

We agree that it is important to review Benedikt’s proposal on platform naming.

We then started discussing features of Spack we’d like to see.  Then we discussed how python modules are managed and how the environment in general is set. Jim wants to see support for chained dependencies and he explained what that means.  Pere says that this concept is very similar to LCG views and would remind us of that presentation.  After the meeting he sent:

* This is an old presentation introducing the [‘views’] (https://indico.cern.ch/event/479888/contribution/1999187/attachments/1217382/1778496/LCG-Views-20160126.pdf)
  Since then there have been several improvements in the selection of what packages form a view. 

In addition to the followup email on priorities of descriptions, we should also discuss how much work to put in on spack issues that we’ve sent them already.  Spack is a quickly moving target.  We should pick a version to start from and stick with it until after the workshop.
