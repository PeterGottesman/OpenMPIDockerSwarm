#!/bin/bash

sudo vzlist -SHo ctid |& while read line ; do sudo vzctl --quiet destroy $line ; done
