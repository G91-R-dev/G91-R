:orphan:

***********
Development
***********


Generating the Manual
=====================

Pre-requisites
--------------

Create a local Pythong virtual environment on Ubuntu:

::

    user$ apt install python3 python3-venv
    user$ python3 -m venv /home/vanosten/bin/virtualenvs/g91r
    user$ source /home/vanosten/bin/virtualenvs/g91r/bin/activate
    (m2000) user$ cd /home/vanosten/G91-R/Docs/manual_rst

    (o2c312) user$ pip3 install -r requirements.txt


Executing the Generation Proces
-------------------------------

Follow the following for generating the manual:

* Create the pdf file locally: Issue command ``sphinx-build -b rinoh . build``
* Copy/overwrite the generated file ``G91-R-FG-manual.pdf`` from the ``build`` directory to the root ``Docs`` folder.


Convention for Section Styling
------------------------------

The following style for titles/sections is used: ``Section conventions⇗ <https://documatt.com/restructuredtext-reference/element/section.html#section-conventions>``.

* L1: Document title ``####`` (above and below - not used)
* L2: Chapters ``****`` (above and below)
* L3: Sections ``====`` (below)
* L4: Subsections ``----`` (below)
* L5: Subsubsections ``^^^^`` (below)
* L6: Paragraphs ``''''`` (below)


External Files
==============

This model is using / tracking files from other modules.

Emesary FrameNotifications
--------------------------

Last copy taken: 2025-10-05

Files:

* https://github.com/Zaretto/f-14b/blob/release/1.12/Nasal/M_frame_notification.nas: no changes
* https://github.com/Zaretto/f-14b/blob/release/1.12/Nasal/M_exec.nas: notifications.frameNotification.FrameCount set to ``8`` instead of ``16`` to increase likelyhood of 1 loop per second


Various Notes
=============

3D Modelling
------------
The .ac file size for the project may seem too much, but it is necessary to have the visual resolution we want. We are aware that it is still possible to remodel some objects to get a smaller dimension to the same quality.


Project Folder Structure
------------------------

For the FDM we try to structure the files strongly, let's not work with folders that have hundreds of files. We want all of the project to be as ordered as possible so that anyone can work without any collateral damage.

Document Folder: Whenever possible, each folder has a subfolder called "Documentation" that contains the objects that were needed for us to develop that single part or feature. This folder is very important and useful, so it needs to be constantly updated. It is sad to see very beautiful projects but they do not report the documentation on which they were based. Of course the inserted material must be compatible with the GPL license GPL 2. Documentation files must be with GPL licensed formats though of course the PDF files (which is an Adobe format) we accept them as a standard of fact. We do not accept Microsoft Office format files, but only files produced by programs that are compatible with GPL.


Textures
--------

The textures are all in .png format and are collected in a subfolder named "Pictures" in each project folder for individual objects. This repetition is necessary to specialize the Textures on each single object. There may be some simplification in the future, but FGFS's XML code currently does not allow to handle a general texture repository for the textures. This means that each Gauge, for example, has its own "Pictures" folder with custom colors for that object.

Colour and Aging
----------------

It is important to customize the colors as we want to create a model for which the inserted objects have their own identity, as in reality.

At present, we do not anticipate an aging of objects, so we want to make a sample of the newly delivered G91-R. The aging of individual parts can happen later, during the development of specific versions or, hopefully, artificially through the in-depth use of ALS functionality.
