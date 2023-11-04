#ifndef JOS_INC_NET_H
#define JOS_INC_NET_H

void net_interrupt_handler();
void net_init();
void
send_packet(void* buff_addr, uint16_t size);

#endif
