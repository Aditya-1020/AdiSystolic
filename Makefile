TB ?= tb_default
SIM = sim

all: run

compile:
	xvlog -sv -f cmds.f

elab: compile
	xelab $(TB) -s $(SIM)

run: elab
	xsim $(SIM) -R

clean:
	rm -rf *.log *.jou *.pb xsim.dir *.wdb $(SIM)