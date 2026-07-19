export type Spot = {
  id: string;
  name: string;
  city: string;
  description: string;
  tags: string[];
  lat: number;
  lng: number;
  checkin_radius_m: number;
};

export type Campaign = {
  id: string;
  title: string;
  slogan: string;
  description: string;
  starts_at: string;
  ends_at: string;
  stamp_goal: number;
  reward: string;
  spot_ids: string[];
};
