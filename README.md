# Anitrack
Tracking of animals 

This program is intended to track single animals (tested on mice and fish). It is also possible to use it for tracking multiple animals, but performance is suboptimal (use it only to get an overview of the group behavior). The program automatically extracts the position of an animal (its centroid) in a defined field of view. This can be done for the whole video or for a defined time window corresponding to an event of interest, such as stimulus delivery. Time of interest can be defined using visual or auditory landmarks, or simply by entering the time in seconds. 

This program has been used to track mice in the following paper:
https://doi.org/10.1101/297226

Prerequisites
Matlab_R2013 or newer versions; for video creation, the QTWriter function: http://horchler.github.io/QTWriter/

Content 
*analysis_videos.m: main script
*video_trace.m: to create a 30 seconds video of the detected animals
*timepoints_visual.m, timepoints_audio.m and timepoints_manual.m: to define window of stimulus presentation
*analysisofdata.m: to perform basics analysis

Input: video in the .mp4, .mov, .m4v, .avi format

Output: 
* nameofvideo_roi.mat (related to section f)
* nameofvideo_background.mat (related to section g and h)
* nameofvideo_output.mat (related to section i)

optional:
* nameofvideo_toi.mat (related to section e)
* nameofvideo_sections.mat (related to section e and i)
* nameofvideo_output.mov (related to section c)

How to run the program

1) Open Matlab
2) Run ''analysis_videos"

In the command window, a series of question will be asked:

a) Name of video? 

b) 'Single tracking (1) or Multitracking (2)?'

c) '30 s video of detected animals?'

d) 'Analysis?'

e) 'Define time window of interest'
Visual (1), auditory (2), manual (3) or whole video (4)?

f) 'Define the field of view' and 'the region of interest' 

g) Background calculation

h) Setting the threshold (for each field of view)

i) Automated detection

j) Analysis (if answered yes in d))

 More details are enclosed in the notice_software.pdf

