.PHONY: unittest perftest symlink clean

MOZILLA_DIR = $(shell echo $(MOZILLA))
OPT_FLAG = $(shell echo $(OPT))

ifeq ($(MOZILLA_DIR),)
$(error Please set the MOZILLA environment variable to your mozilla source tree.)
endif

CXX = clang++

INCLUDES = \
	-I./local \
	-I./tests/unit \
	-I./tests/perf \
	-I$(MOZILLA_DIR)/gfx/2d \
	-I./symlink/A \
	-I./symlink/B \
	-I./symlink/C \
	$(NULL)

DEFINES = USE_SSE2
CXX_FLAGS = -std=gnu++0x -Wall $(INCLUDES) $(addprefix -D,$(DEFINES))

ifeq ($(OPT_FLAG),1)
CXX_FLAGS += -O3
else
CXX_FLAGS += -g -DDEBUG
endif

LD = $(CXX)
LD_FLAGS = $(CXX_FLAGS)

# Tell make where to find the Moz2D sources.
VPATH = $(MOZILLA_DIR)/gfx/2d

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

MOZ2D_OBJS = $(MOZ2D_SRCS:.cpp=.o)
UNITTEST_OBJS = $(UNITTEST_SRCS:.cpp=.o)
PERFTEST_OBJS = $(PERFTEST_SRCS:.cpp=.o)

unittest: $(MOZ2D_OBJS) $(UNITTEST_OBJS)
	make symlink
	$(LD) $(LD_FLAGS) -o $@ $^

perftest: $(MOZ2D_OBJS) $(PERFTEST_OBJS)
	make symlink
	$(LD) $(LD_FLAGS) -o $@ $^

%.o: %.cpp
	$(CXX) $(CXX_FLAGS) -o $@ -c $<

# The mozilla build system copies include headers around. We really don't want to.
symlink:
	rm -rf symlink
	mkdir -p symlink/A && ln -s $(MOZILLA_DIR)/mfbt symlink/A/mozilla
	mkdir -p symlink/B && ln -s $(MOZILLA_DIR)/gfx/2d symlink/B/mozilla
	mkdir -p symlink/C/mozilla && ln -s $(MOZILLA_DIR)/gfx/2d symlink/C/mozilla/gfx

clean:
	rm -rf symlink *.o *~ tests/unit/*.o tests/perf/*.o $(BIN)
