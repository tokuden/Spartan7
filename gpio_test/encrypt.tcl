cd D:/naitou/np1068/CosmozFPGA2019/ip_repo/adcblock/src
file delete adcblock_all.vhd
exec $env(COMSPEC) /c copy *.vhd adcblock_all.vhd
encrypt -key ../../keyfile.txt -ext .vhdp -lang vhd adcblock_all.vhd
file delete adcblock_all.vhd

cd D:/naitou/np1068/CosmozFPGA2019/ip_repo/upp
file delete upp_all.vhd
exec $env(COMSPEC) /c copy *.vhd upp_all.vhd
encrypt -key ../keyfile.txt -ext .vhdp -lang vhd upp_all.vhd
file delete upp_all.vhd

cd D:/naitou/np1068/CosmozFPGA2019/ip_repo/capture
file delete capture_all.vhd
exec $env(COMSPEC) /c copy *.vhd capture_all.vhd
encrypt -key ../keyfile.txt -ext .vhdp -lang vhd capture_all.vhd
file delete capture_all.vhd

cd D:/naitou/np1068/CosmozFPGA2019/ip_repo/pdet
file delete pdet_all.vhd
exec $env(COMSPEC) /c copy *.vhd pdet_all.vhd
encrypt -key ../keyfile.txt -ext .vhdp -lang vhd pdet_all.vhd
file delete pdet_all.vhd

cd D:/naitou/np1068/CosmozFPGA2019/ip_repo/reg_files
file delete reg_files_all.vhd
exec $env(COMSPEC) /c copy *.vhd reg_files_all.vhd
encrypt -key ../keyfile.txt -ext .vhdp -lang vhd reg_files_all.vhd
file delete reg_files_all.vhd

