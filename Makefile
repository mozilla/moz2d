.PHONY: unittest perftest symlink clean

ifeq ($(MOZILLA),)
$(error Please set the MOZILLA variable to your mozilla source tree.)
endif

CXX = clang++
CXX_FLAGS = -std=gnu++0x -Wall

LD = $(CXX)
LD_FLAGS = $(CXX_FLAGS)

INCLUDES = \
	-I./local \
	-I./tests/unit \
	-I./tests/perf \
	-I$(MOZILLA)/gfx/2d \
	-I./symlink/A \
	-I./symlink/B \
	-I./symlink/C \
	$(NULL)

DEFINES = USE_SSE2

ifdef $(OPT)
CXX_FLAGS += -O3
else
CXX_FLAGS += -g -DDEBUG
endif

CXX_FLAGS += $(INCLUDES) $(addprefix -D,$(DEFINES))



# Tell make where to find the Moz2D sources.
VPATH = $(MOZILLA)/gfx/2d

BIN = unittest perftest

MOZ2D_SRCS = \
	Blur.cpp \
	BlurSSE2.cpp \
	DataSourceSurface.cpp \
	DataSurfaceHelpers.cpp \
	DrawEventRecorder.cpp \
	DrawTargetDual.cpp \
	DrawTargetRecording.cpp \
	Factory.cpp \
	FilterNodeSoftware.cpp \
	FilterProcessing.cpp \
	FilterProcessingScalar.cpp \
	FilterProcessingSSE2.cpp \
	ImageScaling.cpp \
	ImageScalingSSE2.cpp \
	Matrix.cpp \
	Path.cpp \
	PathRecording.cpp \
	RecordedEvent.cpp \
	Scale.cpp \
	ScaledFontBase.cpp \
	SourceSurfaceRawData.cpp \
	$(NULL)

UNITTEST_SRCS = \
	$(shell ls ./tests/unit/*.cpp)

PERFTEST_SRCS = \
	$(shell ls ./tests/perf/*.cpp)

ifeq ($(USE_CAIRO),1)
CXX_FLAGS += $(shell pkg-config --cflags cairo)
LD_FLAGS += $(shell pkg-config --libs cairo)
DEFINES  += USE_CAIRO MOZ_ENABLE_FREETYPE

MOZ2D_SRCS += \
	DrawTargetCairo.cpp \
	PathCairo.cpp \
	ScaledFontCairo.cpp \
	SourceSurfaceCairo.cpp \
	$(NULL)

PERFTEST_SRCS += \
	perftest/TestDrawTargetCairoImage.cpp \
	$(NULL)
endif

MOZ2D_OBJS = $(MOZ2D_SRCS:.cpp=.o)
UNITTEST_OBJS = $(UNITTEST_SRCS:.cpp=.o)
PERFTEST_OBJS = $(PERFTEST_SRCS:.cpp=.o)

unittest: symlink $(MOZ2D_OBJS) $(UNITTEST_OBJS)
	$(LD) $(LD_FLAGS) -o $@ $(MOZ2D_OBJS) $(UNITTEST_OBJS)

perftest: symlink $(MOZ2D_OBJS) $(PERFTEST_OBJS)
	$(LD) $(LD_FLAGS) -o $@ $(MOZ2D_OBJS) $(UNITTEST_OBJS)

%.o: %.cpp
	$(CXX) $(CXX_FLAGS) -o $@ -c $<

# The mozilla build system copies include headers around. We really don't want to.
symlink:
	rm -rf symlink
	mkdir -p symlink/A && ln -s $(MOZILLA)/mfbt symlink/A/mozilla
	mkdir -p symlink/B && ln -s $(MOZILLA)/gfx/2d symlink/B/mozilla
	mkdir -p symlink/C/mozilla && ln -s $(MOZILLA)/gfx/2d symlink/C/mozilla/gfx

clean:
	rm -rf symlink *.o *~ tests/unit/*.o tests/perf/*.o $(BIN)
