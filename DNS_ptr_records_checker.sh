#!/bin/bash

# Please set an IPv4 address/subnet as argument 
if [ -z "$1" ]; then
    echo "Please enter IPv4-address, IPv4-address in format CIDR, IPv6-address in CIDR format (i.e. 192.168.0.1, 192.168.0.0/24, 2001:db8::1 ) as argument."
    exit 1
fi

# Put argument value in VARiable
NET=$1

# IPv4 function checker
is_ipv4() {
    if [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}


# IPv6 function checker
is_ipv6() {
    if [[ "$1" =~ ^[0-9a-fA-F:]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Just IPv6 range checker 
is_cidr() {
    if [[ "$1" =~ ^[0-9a-fA-F:.]+/[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# IPv4 and IPv6 Output. Its depends on argument
if is_ipv4 $NET; then
    echo "Введено IPv4-адресу: $NET"
    echo -e "${NET}\t$(dig -x ${NET} +short)"
elif is_ipv6 $NET; then
    echo "Введено IPv6-адресу: $NET"
    echo -e "${NET}\t$(dig -x ${NET} +short)"
else
    if is_cidr $NET; then
        echo "Введено IP-діапазон у форматі CIDR: $NET"
        IFS='/' read -r -a parts <<< "$NET"
        network="${parts[0]}"
        mask="${parts[1]}"
        
        if is_ipv4 $network; then
            for n in $(seq 1 $((2**(32-mask)-2))); do
                ADDR="${network%.*}.${n}"
                echo -e "${ADDR}\t$(dig -x ${ADDR} +short)"
            done
        elif is_ipv6 $network; then
            for n in $(seq 1 $((2**(128-mask)-2))); do
                ADDR="${network}:${n}"
                echo -e "${ADDR}\t$(dig -x ${ADDR} +short)"
            done
        else
            echo "Wrong argument."
            exit 1
        fi
    else
        echo "Wrong format of argument."
        exit 1
    fi
fi

