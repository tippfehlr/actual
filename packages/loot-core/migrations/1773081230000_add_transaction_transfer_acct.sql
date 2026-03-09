BEGIN TRANSACTION;

ALTER TABLE transactions ADD COLUMN transfer_acct TEXT;

-- Populate transfer_acct from existing transfer payees.
-- The description column stores the payee ID (pre-mapping), so we go
-- through payee_mapping to resolve to the canonical payee and then
-- look up its transfer_acct.
UPDATE transactions
SET transfer_acct = (
  SELECT p.transfer_acct
  FROM payee_mapping pm
  JOIN payees p ON p.id = pm.targetId
  WHERE pm.id = transactions.description
)
WHERE transactions.transferred_id IS NOT NULL;

COMMIT;
