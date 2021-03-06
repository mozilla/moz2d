/* -*- Mode: C++; tab-width: 20; indent-tabs-mode: nil; c-basic-offset: 2 -*-
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifdef WIN32

#include "TestDrawTargetD2D.h"

using namespace mozilla;
using namespace mozilla::gfx;

void D2DFlush(void* aTest)
{
  TestDrawTargetD2D* test = static_cast<TestDrawTargetD2D*>(aTest);
  test->Flush();
}

using namespace mozilla::gfx;
TestDrawTargetD2D::TestDrawTargetD2D()
{
}

void
TestDrawTargetD2D::Initialize()
{
  ::D3D10CreateDevice1(nullptr,
                       D3D10_DRIVER_TYPE_HARDWARE,
                       nullptr,
                       D3D10_CREATE_DEVICE_BGRA_SUPPORT |
                       D3D10_CREATE_DEVICE_PREVENT_INTERNAL_THREADING_OPTIMIZATIONS,
                       D3D10_FEATURE_LEVEL_10_0,
                       D3D10_1_SDK_VERSION,
                       byRef(mDevice));

  Factory::SetDirect3D10Device(mDevice);

  mDT = Factory::CreateDrawTarget(BackendType::DIRECT2D, IntSize(DT_WIDTH, DT_HEIGHT), SurfaceFormat::B8G8R8A8);

  mFlush = D2DFlush;
  mDT->ClearRect(Rect(0, 0, DT_WIDTH, DT_HEIGHT));
  Flush();
}

void
TestDrawTargetD2D::Flush()
{
  mDT->Flush();

  RefPtr<ID3D10Query> query;
  D3D10_QUERY_DESC desc;
  desc.Query = D3D10_QUERY_EVENT;
  desc.MiscFlags = 0;
  mDevice->CreateQuery(&desc, byRef(query));
  query->End();
  while (query->GetData(nullptr, 0, 0) == S_FALSE) {}
}

void
TestDrawTargetD2D::Finalize()
{
  mDT = nullptr;
  mDevice = nullptr;
}

#endif
