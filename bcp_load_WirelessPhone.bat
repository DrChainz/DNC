@echo off
for /R "C:\DNC" %%f in (*.txt) do (
	bcp PrivateReserve.DNC.WirelessPhone_%%~nf in %%f -T -fC:\DNC\bcp.fmt -b100000
)
:: bcp PrivateReserve.DNC.WirelessPhone_