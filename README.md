<h1 align="center">LoopRefiner</h1>
<p align="center">LoopRefiner is a system for loop refinement of protein structures based on Modeller and QMEAN</p>
<img src="https://img.shields.io/static/v1?label=PERL&message=5.22&color=green"/>
<img src="https://img.shields.io/static/v1?label=Modeller&message=9%20or%20higher&color=green"/>
<img src="https://img.shields.io/static/v1?label=QMEAN&message=1&color=green"/>

<h4 align="center"> 
	Finished.
</h4>

Table of contents
=================
<!--ts-->
   * [About the system](#-about-the-system)
   * [How it Works](#-how-it-works)
   * [How to run](#-how-to-run)
     * [Prerequisites](#prerequisites)
     * [Running LoopRefiner](#running-looprefiner)
   * [Author](#-author)
   * [License](#-license)
<!--te-->

## About the system
LoopRefiner is a protein structure refinement system.

## How it works
The system uses the loop model from Modeller to refine the strucutres and assess by means of QMEAN API.

Albeit Modeller loop model could refine several loops simultaneously, refine one loop at time is more efficient.

The systems uses asyncronous subroutines to run Modeller on the background while validates the models using the QMEAN API.

## How to run

### Prerequisites
LoopRefinement requires a good internet connection to run the QMEAN API.

Modeller 9 or higher is need to perform the loop refinements.

LoopRefinement uses the JSON (https://metacpan.org/pod/JSON) and Async (https://metacpan.org/pod/Async) modules from PERL. 

Please install before you run the system.

### Running Looprefiner
<pre>
# Clone this repo
$ git clone https://github.com/williamfp7/LoopRefiner.git

# Access the system folder on terminal
$ cd LoopRefiner

# Edit the main.pl file
$ nano main.pl

# Run the system
$ perl main.pl
</pre>
# Author
This system was written by William Farias Porto.
# License
This project is under license [GPL v3](./LICENSE)
