include $(FSLCONFDIR)/default.mk

PROJNAME = ptx2

ifeq ($(FSLMASTERBUILD),1)
    $(eval $($(PROJNAME)_MASTERBUILD))
endif

#OPTFLAGS = -ggdb

#ARCHFLAGS = -arch i386
#ARCHLDFLAGS = -arch i386

ifeq ($(FSLMACHTYPE),apple-darwin8-gcc4.0)
    ARCHFLAGS =  -arch i386 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -I/usr/X11R6/include/
    ARCHLDFLAGS = -Wl,-search_paths_first -arch i386 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -L/Developer/SDKs/MacOSX10.4u.sdk/usr/X11R6/lib/
endif

ifeq ($(COMPILE_GPU), 1)
    COMPILE_WITH_GPU=probtrackx2_gpu
endif

USRINCFLAGS = -I${INC_NEWMAT} -I${INC_NEWRAN} -I${INC_CPROB} -I${INC_BOOST} -I${INC_ZLIB}
USRLDFLAGS = -L${LIB_NEWMAT} -L${LIB_NEWRAN} -L${LIB_CPROB} -L${LIB_ZLIB}

DLIBS =  -lnewmeshclass -lwarpfns -lbasisfield -lfslsurface  -lfslvtkio -lmeshclass -lnewimage -lutils -lmiscmaths -lnewran -lNewNifti -lgiftiio -lexpat -lfirst_lib -lznz -lcprob -lutils -lm -lz

CCOPS=ccops
PTX=probtrackx2
FTB=find_the_biggest
PJ=proj_thresh
FMO=fdt_matrix_ops
FMS=fdt_matrix_split
TEST=testfile

CCOPSOBJS=ccops.o ccopsOptions.o
PTXOBJS=probtrackx.o probtrackxOptions.o streamlines.o ptx_simple.o ptx_seedmask.o ptx_nmasks.o csv.o csv_mesh.o
FTBOBJS=find_the_biggest.o csv_mesh.o
PJOBJS=proj_thresh.o csv_mesh.o
FMOOBJS=fdt_matrix_ops.o
FMSOBJS=fdt_matrix_split.o
TESTOBJS=testfile.o streamlines.o csv.o csv_mesh.o probtrackxOptions.o

SURFDATA=surf_proj
SURFDATAOBJS=surf_proj.o csv.o csv_mesh.o
MATMERGE=fdt_matrix_merge
MATMERGEOBJS=fdt_matrix_merge.o streamlines.o csv.o csv_mesh.o probtrackxOptions.o
MAT42=fdt_matrix_4_to_2
MAT42OBJS=fdt_matrix_4_to_2.o

S2S=surf2surf
S2SOBJS=surf2surf.o csv.o csv_mesh.o
S2V=surf2volume
S2VOBJS=surf2volume.o csv.o csv_mesh.o
L2S=label2surf
L2SOBJS=label2surf.o csv_mesh.o
SM=surfmaths
SMOBJS=surfmaths.o

PTX_GPUOBJS=link_gpu.o saveResults_ptxGPU.o probtrackx_gpu.o CUDA/tractographyInput.o CUDA/tractographyData.o probtrackxOptions.o csv.o csv_mesh.o

XFILES = probtrackx2 surfmaths surf2surf surf2volume surf_proj label2surf find_the_biggest proj_thresh fdt_matrix_merge ${COMPILE_WITH_GPU}

all: ${XFILES}

${CCOPS}: ${CCOPSOBJS}
	${CXX} ${CXXFLAGS} ${LDFLAGS} -o $@ ${CCOPSOBJS} ${DLIBS}

${PTX}: ${PTXOBJS}
	${CXX} ${CXXFLAGS} ${LDFLAGS} -o $@ ${PTXOBJS} ${DLIBS}

${FTB}: ${FTBOBJS}
	${CXX} ${CXXFLAGS} ${LDFLAGS} -o $@ ${FTBOBJS} ${DLIBS}

${PJ}: ${PJOBJS}
	${CXX} ${CXXFLAGS} ${LDFLAGS} -o $@ ${PJOBJS} ${DLIBS}

${FMO}: ${FMOOBJS}
	${CXX} ${CXXFLAGS} ${LDFLAGS} -o $@ ${FMOOBJS} ${DLIBS}

${FMS}: ${FMSOBJS}
	${CXX} ${CXXFLAGS} ${LDFLAGS} -o $@ ${FMSOBJS} ${DLIBS}

${TEST}: ${TESTOBJS}
	${CXX} ${CXXFLAGS} ${LDFLAGS} -o $@ ${TESTOBJS} ${DLIBS}

${SURFDATA}: ${SURFDATAOBJS}
	${CXX} ${CXXFLAGS} ${LDFLAGS} -o $@ ${SURFDATAOBJS} ${DLIBS}

${MATMERGE}: ${MATMERGEOBJS}
	${CXX} ${CXXFLAGS} ${LDFLAGS} -o $@ ${MATMERGEOBJS} ${DLIBS}

${MAT42}: ${MAT42OBJS}
	${CXX} ${CXXFLAGS} ${LDFLAGS} -o $@ ${MAT42OBJS} ${DLIBS}

${S2S}: ${S2SOBJS}
	${CXX} ${CXXFLAGS} ${LDFLAGS} -o $@ ${S2SOBJS} ${DLIBS}

${S2V}: ${S2VOBJS}
	${CXX} ${CXXFLAGS} ${LDFLAGS} -o $@ ${S2VOBJS} ${DLIBS}

${L2S}: ${L2SOBJS}
	${CXX} ${CXXFLAGS} ${LDFLAGS} -o $@ ${L2SOBJS} ${DLIBS}

${SM}:  ${SMOBJS}
	${CXX} ${CXXFLAGS} ${LDFLAGS} -o $@ ${SMOBJS} ${DLIBS}

probtrackx2_gpu: ${PTX_GPUOBJS}
	${CXX} ${CXXFLAGS} ${LDFLAGS} -o probtrackx2_gpu ${PTX_GPUOBJS} tractography_gpu.o ${DLIBS} -I${INC_CUDA} -lcudart -lcudadevrt -lcuda -lnvToolsExt -L${LIB_CUDA} -L${LIB_CUDA}/stubs

link_gpu.o:	tractography_gpu.o
	$(NVCC) ${GENCODE_FLAGS} -dlink tractography_gpu.o -o link_gpu.o -L${LIB_CUDA}

tractography_gpu.o:
	$(NVCC) ${GENCODE_FLAGS} -I$(INC_CUDA) -I${FSLDIR}/include -I${INC_NEWMAT} -I${INC_BOOST} -I. -O3 -dc -maxrregcount=64 -Xptxas -v CUDA/tractography_gpu.cu
