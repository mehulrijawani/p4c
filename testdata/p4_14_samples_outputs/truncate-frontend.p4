#include <core.p4>
#include <v1model.p4>

header hdrA_t {
    bit<8>  f1;
    bit<64> f2;
}

struct metadata {
}

struct headers {
    @name("hdrA") 
    hdrA_t hdrA;
}

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".start") state start {
        packet.extract<hdrA_t>(hdr.hdrA);
        transition accept;
    }
}

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("._nop") action _nop_0() {
    }
    @name("._truncate") action _truncate_0(bit<32> new_length, bit<9> port) {
        standard_metadata.egress_spec = port;
        truncate(new_length);
    }
    @name(".t_ingress") table t_ingress_0 {
        actions = {
            _nop_0();
            _truncate_0();
            @defaultonly NoAction();
        }
        key = {
            hdr.hdrA.f1: exact @name("hdr.hdrA.f1") ;
        }
        size = 128;
        default_action = NoAction();
    }
    apply {
        t_ingress_0.apply();
    }
}

control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        packet.emit<hdrA_t>(hdr.hdrA);
    }
}

control verifyChecksum(in headers hdr, inout metadata meta) {
    apply {
    }
}

control computeChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

V1Switch<headers, metadata>(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;
