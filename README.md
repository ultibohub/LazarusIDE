# Lazarus Source code repository

## Ultibo Edition

This repository contains the Ultibo Edition of the Lazarus IDE which is currently based on Lazarus 4.2 (Fixes 4.3 / Main 4.99).

You can choose from either the [Stable](https://github.com/ultibohub/LazarusIDE/tree/ultibo-4.2.0), [Fixes](https://github.com/ultibohub/LazarusIDE/tree/ultibo-4.0) or [Main](https://github.com/ultibohub/LazarusIDE/tree/ultibo) branches.

For all information on developing with Ultibo, building the source and getting started please see the [Ultibo.org website](https://ultibo.org)

To obtain a prepackaged installer for Windows or an install script for Linux please see the Ultibo [downloads page](https://ultibo.org/download/)

Welcome to Lazarus
==================

Lazarus is a Rapid Application Development Tool for Free Pascal.
It comes with the LCL - Lazarus component library, which contains platform
independent visual components like buttons, windows, checkbox, treeview and
many, many more. The LCL is platform independent, so you can write an
application once and then compile for various platforms without changing code.

[Free Pascal](https://www.freepascal.org) is a fast Object Pascal compiler,
that runs on more than 20 platforms (Linux, Windows, BSD, OS/2, DOS, PowerPC,
and many more).

The LCL currently supports:
* Linux/FreeBSD (GTK2, Qt4, Qt5 and Qt6)
* all flavors of Windows (even WinCE)
* macOS (Cocoa, Carbon, GTK2, Qt4, Qt5, Qt6)

There is an experimental support for:
* GTK3
* Solaris 

The LCL still contains code for GTK1, although this target is obsolete.

### Compilation

You don't need ```./configure```, just do  
```make clean bigide``` (```gmake clean bigide``` in BSD).

This will create the Lazarus executable with a lot of packages.
Start it and enjoy.

If the above gives an error, you can try to build a minimal IDE with  
```make clean all``` (```gmake clean all``` in BSD).

### Installation and Requirements

See [Lazarus Wiki](https://wiki.freepascal.org/Category:Install) for details.

### Usage

Start the IDE with:
```shell
cd your/lazarus/directory
./lazarus
```

### Documentation

The official site is www.lazarus-ide.org.
Documents about specific topics can be found at 
https://wiki.freepascal.org/Lazarus_Documentation.
Examples on how to use the LCL can be found in the [examples](examples) directory.
Help, documents and files about Free Pascal are at www.freepascal.org.

### Mailing list

There is a very active and helpful mailing list for Lazarus, where the
developers interact, share ideas, discuss problems, and of course answer
questions.
You can subscribe at
http://lists.lazarus.freepascal.org/mailman/listinfo/lazarus.

### How to help Lazarus

If you find bugs, don't hesitate to use issue tracker,
or send an email to the list.
Lazarus source code and issue tracker are located at [GitLab](https://gitlab.com/freepascal.org/lazarus/lazarus).
