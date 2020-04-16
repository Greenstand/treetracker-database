select trees.id, entity.active_contract_id from trees join planter on planter.id = trees.planter_id join entity on entity.id = planter.person_id and trees.contract_id IS NULL;

then assign the contract id to the tree id

then we can check the contract


SELECT * FROM contract WHERE id = 1



// actually
//
//
//

select * from trees join planter on trees.planter_id = planter.id
JOIN entity 
ON entity.id = planter.organization_id
where token_issued = false 
AND entity.offering_pay_to_plant = true

then issue a token for that tree to this organization id
