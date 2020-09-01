VOXELYZE_NAME = voxelyze
VOXELYZE_LIB_NAME = lib$(VOXELYZE_NAME)

CC = /usr/local/opt/llvm/bin/clang++
INCLUDE = -I./include -I/usr/local/opt/llvm/include -L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib -fopenmp
FLAGS = -std=c++17 -Ofast -DUSE_OMP=1 -fPIC $(INCLUDE)

VOXELYZE_SRC = \
	src/Voxelyze.cpp \
	src/VX_Voxel.cpp \
	src/VX_External.cpp \
	src/VX_Link.cpp \
	src/VX_Material.cpp \
	src/VX_MaterialVoxel.cpp \
	src/VX_MaterialLink.cpp \
	src/VX_Collision.cpp \
	src/VX_LinearSolver.cpp \
	src/My_MeshRender.cpp 

VOXELYZE_OBJS = \
	src/Voxelyze.o \
	src/VX_Voxel.o \
	src/VX_External.o \
	src/VX_Link.o \
	src/VX_Material.o \
	src/VX_MaterialVoxel.o \
	src/VX_MaterialLink.o \
	src/VX_Collision.o \
	src/VX_LinearSolver.o \
	src/My_MeshRender.o
		
.PHONY: clean all

# Dummy target that builds everything for the library
all: $(VOXELYZE_LIB_NAME).so $(VOXELYZE_LIB_NAME).a
	
# Auto sorts out dependencies (but leaves .d files):
%.o: %.cpp
#	@echo making $@ and dependencies for $< at the same time
	@$(CC) -c $(FLAGS) -o $@ $<
	@$(CC) -MM -MP $(FLAGS) $< -o $*.d

-include *.d

# Make shared dynamic library
$(VOXELYZE_LIB_NAME).so:	$(VOXELYZE_OBJS)
	$(CC) -shared $(INCLUDE) -o lib/$@ $^

# Make a static library
$(VOXELYZE_LIB_NAME).a:	$(VOXELYZE_OBJS)
	ar rcs lib/$(VOXELYZE_LIB_NAME).a $(VOXELYZE_OBJS)

clean:
	rm -rf *.o */*.o *.d */*.d lib/$(VOXELYZE_LIB_NAME).a lib/$(VOXELYZE_LIB_NAME).so