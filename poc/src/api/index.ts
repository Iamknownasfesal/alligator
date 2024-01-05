import { Route } from "../types/route";

const SWAPPER_1_RATIO = 0.19;
const SWAPPER_2_RATIO = 0.81;

// And lets assume that you give 1 sui to 2 target coins
// Swapper 1 gives 2.1 sui but after 0.19 it will give 1.98 sui
// Swapper 2 gives 2.1 sui but after 0.81 it will give 1.99 sui
// So routing should be like this:
// 1. Get 1 sui from the source
// 2. Send 0.19 sui to swapper 1
// 3. Send 0.81 sui to swapper 2
// 4. Get target from swapper 1
// 5. Get target from swapper 2
// 6. Send 3,98 target back to the owner

export async function fetchRoute(
  addr: string,
  sourceAmount: string,
  toAddr: string
): Promise<Route> {
  // Do some stuff, like fetching from alligator.io/api/quote
  // and return a Route object
  return {
    source: addr,
    target: toAddr,
    sourceAmount: sourceAmount,
    targetAmount: "300",
    paths: [
      {
        path: {
          source: addr,
          target: toAddr,
          sourceAmount: "1900000",
          targetAmount: "198",
          swapperFunction:
            "0x9c64f177d5d8dba24330c04feb4c5542510d11fe2fcff9da0ef6b31c331ad32d::swap::swap_x_to_y_direct",
          swapperPool:
            "0xe1f68ccb00eadf47682e585f7a874311085a598f835cd798608d50c19e0349a0",
        },
        weight: SWAPPER_1_RATIO,
      },
      {
        path: {
          source: addr,
          target: toAddr,
          sourceAmount: "8100000",
          targetAmount: "202",
          swapperFunction:
            "0x061fb2da3c48899487106e5b4ade6da596e5af4c397f82758e334cd837c0af78::swap::swap_x_to_y_direct",
          swapperPool:
            "0x53035b168d96ae2765fed5e7dbf4ab3671132195b3945fabdca89841498afd0b",
        },
        weight: SWAPPER_2_RATIO,
      },
    ],
  };
}
