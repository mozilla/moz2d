#ifndef __fake_prlog_h__
#define __fake_prlog_h__

#define PR_LOG_DEBUG 0
#define PR_LOG_WARNING 1

typedef int PRLogModuleLevel;

struct PRLogModuleInfo {
};

static inline PRLogModuleInfo* PR_NewLogModule(const char *aName) {
  return nullptr;
}

#endif
