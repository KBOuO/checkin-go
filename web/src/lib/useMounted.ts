"use client";

import { useEffect, useState } from "react";

// localStorage 狀態（收藏）與倒數計時只能在 client 呈現，
// 用 mounted 閘門避免 SSR/hydration 內容不一致
export function useMounted() {
  const [mounted, setMounted] = useState(false);
  useEffect(() => setMounted(true), []);
  return mounted;
}
