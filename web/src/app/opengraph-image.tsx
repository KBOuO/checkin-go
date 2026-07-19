import { ImageResponse } from "next/og";

export const size = { width: 1200, height: 630 };
export const contentType = "image/png";
export const alt = "CheckinGo — Island Stamp Season 2026";

// Satori 預設字型不含 CJK，OG 圖以英文呈現避免缺字
export default function OgImage() {
  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          justifyContent: "center",
          gap: 24,
          background: "linear-gradient(160deg, #062a38 0%, #0e7490 55%, #22b8cf 100%)",
        }}
      >
        <div
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            width: 120,
            height: 120,
            borderRadius: "50%",
            border: "6px dashed rgba(255,255,255,0.6)",
            transform: "rotate(-8deg)",
            color: "#fdba74",
            fontSize: 56,
            fontWeight: 700,
          }}
        >
          GO
        </div>
        <div style={{ color: "#ffffff", fontSize: 92, fontWeight: 700 }}>
          CheckinGo
        </div>
        <div style={{ color: "#fed7aa", fontSize: 40 }}>
          Island Stamp Season 2026
        </div>
        <div style={{ color: "#a5f3fc", fontSize: 26 }}>
          12 spots · GPS check-in · collect stamps
        </div>
      </div>
    ),
    { ...size },
  );
}
