# CronParser
A script to parse lines cronjob scheduling configuration from a text file.

## Run as command line script
Run with `cat [input file] | ./CronParser.swift [hh:mm]`
e.g. `cat input.txt | ./CronParser.swift 00:02`

## Run as Xcode project
Open the project and hit cmd-u to run unit tests against "Script" class.
