.section .vectors, "ax"
	LDR PC, =SERVICE_RESET // reset vector
	LDR PC, =SERVICE_UND // undefined instruction vector
	LDR PC, =SERVICE_SVC // software interrrupt vector
	LDR PC, =SERVICE_ABT_INST // aborted prefetch vector
	LDR PC, =SERVICE_ABT_DATA // aborted data vector
	.word 0 // unused vector
	LDR PC, =SERVICE_IRQ // IRQ interrupt vector
	LDR PC, =SERVICE_FIQ // FIQ interrupt vector


.global _start
_start:
	MOV R1, #0b11010010
	MSR CPSR_c, R1 // change to IRQ mode with interrupts disabled
	LDR SP, =0xFFFFFFFC // set IRQ stack to top of A9 on-chip memory
	MOV R1, #0b11010011
	MSR CPSR_c, R1 // change to SVC mode with interrupts disabled
	LDR SP, =0x3FFFFFFC // set SVC stack to top of DDR3 memory
	BL CONFIG_GIC // configure the ARM generic interrupt controller
	

	BL CONFIG_PS2// ### TODO //CONFIGURE DEVICE




	/* enable IRQ interrupts in the processor */
	EOR R0,R0
	EOR R1,R1
	EOR R2,R2
	EOR R3,R3
	MOV R1, #0b01010011 // IRQ unmasked, MODE = SVC
	MSR CPSR_c, R1
	EOR R1,R1

loop:
	MVN R0,R0
	B loop



/* Configure the Generic Interrupt Controller (GIC) */
CONFIG_GIC:
									
	
//	... ##TODO Configure other GIC registers


	/* configure the GIC CPU interface */
	LDR R0, =0xFFFEC100 // base address of CPU interface
	/* Set Interrupt Priority Mask Register (ICCPMR) */
	LDR R1, =0xFF // enable interrupts of all priorities levels
	STR R1, [R0, #0x04] // ICCPMR
	/* Set the enable bit in the CPU Interface Control Register (ICCICR). This bit allows
	* interrupts to be forwarded to the CPU(s) */
	MOV R1, #1
	STR R1, [R0, #0x00] // ICCICR
	/* Set the enable bit in the Distributor Control Register (ICDDCR). This bit allows
	* the distributor to forward interrupts to the CPU interface(s) */
	LDR R0, =0xFFFED000
	STR R1, [R0, #0x00] // ICDDCR
	LDR R0, =0xFFFED81C   //[29/4]*4=28=0x1C
	LDR R1, =0x100        //29%4=1
	STR R1, [R0]
	LDR R0, =0xFFFED84C     //[79/4]*4=76=0x4C
	LDR R1, =0x1000000              //79%4=3
	STR R1, [R0]
	LDR R0, =0xFFFED100
	LDR R1, =0x20000000
	STR R1, [R0]
	LDR R0, =0xFFFED108      //[79/32]*4=8
	LDR R1, =0x8000                 //79%32=15 1000 0000 0000 0000
	STR R1, [R0]
	BX LR 
	

	

//	... ## TODO Configure the device
CONFIG_PS2:
	LDR R0, =0xff200100
	MOV R1, #1
	STR R1, [R0, #0x4]
	BX LR
CONFIG_TIMER:
	PUSH {R0-R7, LR}
	LDR R0, =0xfffec600
	LDR R1, =400000000
	STR R1, [R0]
	MOV R1, #7
	STR R1, [R0, #0x8]
	POP {R0-R7, LR}
	BX LR

.global SERVICE_IRQ
SERVICE_IRQ:
	PUSH {R0-R7, LR} // save registers
	
	/* get the interrupt ID from the GIC */
	LDR R4, =0xFFFEC100 // GIC CPU interface base address
	LDR R5, [R4, #0x0C] // read the ICCIAR




//	... ## TODO Check the proper interrupt ID
	CMP R5, #79							
	BNE	CHECK_TIMER 	 // if not recognized, stop here
	BL PS2_ISR
	BAL EXIT_IRQ
CHECK_TIMER:
	CMP R5, #29
UNEXPECTED:
	BNE UNEXPECTED
	BL 	TIMER_ISR
EXIT_IRQ:
	STR R5, [R4, #0x10] // Write to end-of-interrupt register (ICCEOIR)
	POP {R0-R7, LR}

	SUBS PC, LR, #4

// ---------------------------- ALL OF THE ISR TO A LOOP
.global SERVICE_RESET /* Reset */
SERVICE_RESET:
	B _start
.global SERVICE_UND /* Undefined instructions */
SERVICE_UND:
	B SERVICE_UND
.global SERVICE_SVC /* Software interrupts */
SERVICE_SVC:
	B SERVICE_SVC
.global SERVICE_ABT_DATA /* Aborted data reads */
SERVICE_ABT_DATA:
	B SERVICE_ABT_DATA
.global SERVICE_ABT_INST /* Aborted instruction fetch */
SERVICE_ABT_INST:
	B SERVICE_ABT_INST
.global SERVICE_FIQ /* FIQ */
SERVICE_FIQ:
	B SERVICE_FIQ





.global ISR 

	
//	... ##TODO define the ISR
PS2_ISR:
	PUSH {R0-R7, LR}
	LDR R0, =0xFF200100
	LDRB R1, [R0]
	CMP R1, #0x2D
	BNE end
	LDRB R1, [R0]
	CMP R1, #0xF0
	BNE end
	LDRB R1, [R0]
	LDRB R1, [R0]
	CMP R1, #0x1C
	BNE end
	LDRB R1, [R0]
	CMP R1, #0xF0
	BNE end
	LDRB R1, [R0]
	LDRB R1, [R0]
	CMP R1, #0x43
	BNE end
	LDRB R1, [R0]
	CMP R1, #0xF0
	BNE end
	LDRB R1, [R0]
	LDRB R1, [R0]
	CMP R1, #0x31
	BNE end
	LDRB R1, [R0]
	CMP R1, #0xF0
	BNE end
	LDRB R1, [R0]
	LDRB R1, [R0]
	CMP R1, #0x32
	BNE end
	LDRB R1, [R0]
	CMP R1, #0xF0
	BNE end
	LDRB R1, [R0]
	LDRB R1, [R0]
	CMP R1, #0x44
	BNE end
	LDRB R1, [R0]
	CMP R1, #0xF0
	BNE end
	LDRB R1, [R0]
	LDRB R1, [R0]
	CMP R1, #0x1D
	BNE end
	BL CONFIG_TIMER
	LDR R0, =0xC8000000
	MOV R1, #0
	MOV R2, #0
	MOV R3, #0xF800 //red
	MOV R4, #2
	MOV R5, #1024
loop1:
	CMP R1, #320
	BEQ loop2
	MUL R6, R1, R4
	MUL R7, R2, R5
	ADD R7, R7, R6
	STRH R3, [R0, R7]
	ADD R1, R1, #1
	BAL loop1
loop2:
	MOV R1, #0
	ADD R2, R2, #1
	CMP R2, #40
	BEQ orange
	CMP R2, #80
	BEQ yellow
	CMP R2, #120
	BEQ green
	CMP R2, #160
	BEQ blue
	CMP R2, #200
	BEQ purple
	CMP R2, #240
	BEQ end
	BAL loop1
orange:
	MOV R3, #0xfcc0
	BAL loop1
yellow:
	MOV R3, #0xffe0
	BAL loop1
green:
	MOV R3, #0x07e0  
	BAL loop1
blue:
	MOV R3, #0x001f
	BAL loop1
purple:
	MOV R3, #0xF81F
	BAL loop1
end:
	POP {R0-R7, LR}
	BX LR							
TIMER_ISR:
	PUSH {R0-R7, LR}
	LDR R0, =0xfffec60C
	LDR R1, [R0]
	STR R1, [R0]
	LDR R0, =0xC8000000
	LDRH R1, [R0]
	CMP R1, #0xF800
	BEQ trans
	MOV R1, #0
	MOV R2, #0
	MOV R3, #0xF800 //red
	MOV R4, #2
	MOV R5, #1024
loop12:
	CMP R1, #320
	BEQ loop22
	MUL R6, R1, R4
	MUL R7, R2, R5
	ADD R7, R7, R6
	STRH R3, [R0, R7]
	ADD R1, R1, #1
	BAL loop12
loop22:
	MOV R1, #0
	ADD R2, R2, #1
	CMP R2, #40
	BEQ orange2
	CMP R2, #80
	BEQ yellow2
	CMP R2, #120
	BEQ green2
	CMP R2, #160
	BEQ blue2
	CMP R2, #200
	BEQ purple2
	CMP R2, #240
	BEQ end1
	BAL loop12
orange2:
	MOV R3, #0xfcc0
	BAL loop12
yellow2:
	MOV R3, #0xffe0
	BAL loop12
green2:
	MOV R3, #0x07e0  
	BAL loop12
blue2:
	MOV R3, #0x001f
	BAL loop12
purple2:
	MOV R3, #0xF81F
	BAL loop12
trans:
	MOV R1, #0
	MOV R2, #0
	MOV R3, #0x5e7e
	MOV R4, #2
	MOV R5, #1024
loop11:
	CMP R1, #320
	BEQ loop21
	MUL R6, R1, R4
	MUL R7, R2, R5
	ADD R7, R7, R6
	STRH R3, [R0, R7]
	ADD R1, R1, #1
	BAL loop11
loop21:
	MOV R1, #0
	ADD R2, R2, #1
	CMP R2, #48
	BEQ pink
	CMP R2, #96
	BEQ white1
	CMP R2, #144
	BEQ pink
	CMP R2, #192
	BEQ blue1
	CMP R2, #240
	BEQ end1
	BAL loop11
pink:
	MOV R3, #0xf556
	BAL loop11
white1:
	MOV R3, #0xffff
	BAL loop11
blue1:
	MOV R3, #0x5e7e
	BAL loop11
end1:
	POP {R0-R7, LR}
	BX LR
	
.end



	
	
	
	