# Queues



:for rosjb from=1 to=254 do={/queue simple add name=("PC".$rosjb) target=("10.0.10." . $rosjb) dst=ether7 limit-at=6M/6M max-limit=6M/6M priority=8/8}

:for ros from=1 to=254 do={/queue simple add name=("NC".$ros) target=("10.0.0." . $ros) dst=ether7 limit-at=4M/4M max-limit=4M/4M priority=8/8}

:for cos from=1 to=254 do={/queue simple add name=("COC".$cos) target=("192.168.0." . $cos) dst=ether7 limit-at=4M/4M max-limit=4M/4M priority=8/8}

:for aos from=1 to=254 do={/queue simple add name=("BC".$aos) target=("10.0.2." . $aos) dst=ether7 limit-at=4M/4M max-limit=4M/4M priority=8/8}

:for bos from=1 to=254 do={/queue simple add name=("CC".$bos) target=("10.0.3." . $bos) dst=ether7 limit-at=4M/4M max-limit=4M/4M priority=8/8}

:for dos from=1 to=254 do={/queue simple add name=("doC".$dos) target=("10.0.6." . $dos) dst=ether7 limit-at=4M/4M max-limit=4M/4M priority=8/8}