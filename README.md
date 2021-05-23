# ZeTap

THE Translation Auto Processor

## Intro

ZeTap.cmd: A simple launcher. Drag the Batch Files into.

vim: The editor.

ZeTap.vim: Auto process engine.

loc_example.txt: ZeTap Batch File, for translating the file.

restore_example.txt: ZeTap Batch File, for restoring the file from bak.

## Have a try

Drag restore_example.txt into ZeTap.cmd.

example.js was restored.

Then drag loc_example.txt into.

example.js was translated.

Nice.

## Grammar

### Text Replacing

__#__ Replace

__$__ Replace, auto escape

Followed by a ' ' command means Replace Target

    #a
     b
    [a --> b]
    
    $Files
     文件(&F)
    ['&' autoescape '\&']

Replace multiple lines are supported.

    #a
    #aa
     b
     bb
    
    [a      b
     aa --> bb]
     
### File Operations

__<__ Open a file, close others

__<<__ Just open

__>__ Save & close *

__>>__ Save but not close *

__x__ Delete *

__b__ Backup *

__r__ Restore *

(*: Leave blank for all files opened)

### Execute

__:__ Vim command

### Comment

    //Comment
    /*Looooooooooong
    comment
    */

### Set Range (not finished yet)

__?__ Search & jump
__[__ Set front boundary
__]__ Set back boundary
__[]__ Reset
