import { Chance } from "chance";
import { findSchema } from "../../../src/validations/unregisted";
import { validateSchema } from "../../utils";

const chance = new Chance();
describe("Unregisted Schemas", () => {

    describe("sucess", () =>{

        it("findSchema", () =>{
            const params = {
                query:{
                    search: JSON.stringify({name: chance.name()}),
                    sortBy: chance.name(),
                    orderBy: chance.pickone(["asc", "desc"]),
                    limit: 10
                }
            };
            const res = validateSchema(findSchema, params);
            expect(res).toBeDefined();
            expect(res).toHaveProperty("query");
        });
        
    });
    
    describe("error", ()=>{

        it("findSchema - Only object type", () =>{
            const params = {
                query:{
                    search: chance.name(),
                    sortBy: chance.name(),
                    orderBy: chance.pickone(["asc", "desc"]),
                    limit: 10
                }
            };

            expect(() => validateSchema(findSchema, params)).toThrowError("Only object type");
        });

    });
});