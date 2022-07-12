OUTPUT_FOLDER=images/
SRC_FOLDER=src/
INT_FOLDER=int/
ASSEMBLY_FOLDER=asm/
FINAL_IMAGE=$(OUTPUT_FOLDER)OS.img
VM=qemu-system-i386

$(FINAL_IMAGE): $(OUTPUT_FOLDER)bootloader.img
	cat $^ > $(FINAL_IMAGE)

run: $(FINAL_IMAGE)
	$(VM) $(FINAL_IMAGE)

$(OUTPUT_FOLDER)bootloader.img: $(INT_FOLDER)$(ASSEMBLY_FOLDER)mbr.bin $(SRC_FOLDER)$(ASSEMBLY_FOLDER)print_16bit.asm
	cat $< > $@

$(INT_FOLDER)$(ASSEMBLY_FOLDER)%.bin: $(SRC_FOLDER)$(ASSEMBLY_FOLDER)%.asm
	nasm -f bin -o $@ $^

clean:
	find $(INT_FOLDER) -type f -delete
	find $(OUTPUT_FOLDER) -type f -delete

