import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can create new cooking session",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    let wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("session", "create-session", [
        types.utf8("Pizza Recipe"),
        types.uint(5),
        types.uint(100000),
        types.uint(3600)
      ], wallet_1.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    assertEquals(block.receipts[0].result, "(ok u0)");
  }
});

Clarinet.test({
  name: "Can join existing session",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    // Test implementation
  }
});
