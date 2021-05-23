# ZeTap

The Translation Auto Processor

0.2.0 test

## Intro

__ZeTap.cmd__: A simple launcher. Drag the Batch Files into.

__vim__: The editor.

__ZeTap.vim__: Auto process engine.

__example.js & .bak__: Example

__loc_example.txt__: ZeTap Batch File, for translating the example file.

__restore_example.txt__: ZeTap Batch File, for restoring the example file from bak.

## Have a try

Drag __restore_example.txt__ into __ZeTap.cmd__.

__example.js__ was restored.

Then drag __loc_example.txt__ into.

__example.js__ was translated.

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

#### ⚠ These grammars may change at any time.
#### Err... before 1.0.0.
