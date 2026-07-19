"use client";

import { MotionConfig } from "framer-motion";

// reducedMotion="user"：系統開啟「減少動態效果」時自動停用非必要動畫
export function Providers({ children }: { children: React.ReactNode }) {
  return <MotionConfig reducedMotion="user">{children}</MotionConfig>;
}
