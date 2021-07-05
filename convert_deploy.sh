#!/bin/bash

quartus_cpf -c output_file.cof
cp output_file.rbf /run/media/jacky/E0B0-FE35/soc_system.rbf
umount /run/media/jacky/E0B0-FE35
