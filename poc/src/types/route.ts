export type Route = {
  source: string;
  target: string;
  sourceAmount: string;
  targetAmount: string;
  paths: Path[];
};

export type Path = {
  path: Jump;
  weight: number;
};

export type Jump = {
  source: string;
  target: string;
  sourceAmount: string;
  targetAmount: string;
  swapperFunction: `${string}::${string}::${string}`;
  swapperPool: string;
};
