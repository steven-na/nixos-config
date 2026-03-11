{ pkgs, ... }:
{
    home.packages = [
        # networking / recon
        pkgs.nmap
        pkgs.netcat-gnu # nc
        pkgs.socat
        pkgs.curl
        pkgs.wget
        pkgs.httpie # human-friendly curl alternative
        pkgs.xh # even faster httpie alternative (rust)

        # diagnostics / monitoring
        pkgs.iproute2 # ip, ss
        pkgs.nettools # ifconfig, netstat, route
        pkgs.traceroute
        pkgs.mtr # traceroute + ping combined
        pkgs.iperf3 # bandwidth testing
        pkgs.bandwhich # per-process bandwidth usage (rust)
        pkgs.nload # realtime traffic graphs

        # dns
        pkgs.dig # or pkgs.bind (includes dig, nslookup)
        pkgs.dog # modern dig alternative (rust)
        pkgs.whois

        # packet capture / analysis
        pkgs.tcpdump

        # http / api
        pkgs.websocat # websocket debugging
        pkgs.grpcurl # gRPC debugging

        # tunneling / proxy
        pkgs.wireguard-tools
        pkgs.openssh
        pkgs.cloudflared # cloudflare tunnel

        # misc
        pkgs.lsof
        pkgs.sipcalc # subnet/IP calculator
    ];
}
