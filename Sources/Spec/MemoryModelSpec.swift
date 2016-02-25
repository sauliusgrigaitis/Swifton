import Quick
import Nimble
import Swifton

class MemoryModelSpec: QuickSpec {
    override func spec() {
        describe("MemoryModel") {
            var record:TestModel!
            beforeEach {
                TestModel.all = [MemoryModel]()
                record = TestModel.create(["name": "Saulius", "surname": "Grigaitis"])
            }

            it("adds record to 'all' collection") {
                expect(TestModel.all).to(equal([record!]))
            }

            it("finds record by id:String") {
                let expected = TestModel.find(String(record.id))
                expect(record).to(equal(expected))
            }

            it("finds record by id:Int") {
                let expected = TestModel.find(record.id)
                expect(record).to(equal(expected))
            }

            it("accesses records's attribute via subscript") {
                expect(String(record["name"]!)).to(equal("Saulius"))
                expect(String(record["surname"]!)).to(equal("Grigaitis"))
            }

            it("updates record") {
                record.update(["name": "James", "surname": "Bond"])
                expect(String(record["name"]!)).to(equal("James"))
                expect(String(record["surname"]!)).to(equal("Bond"))
            }

            it("destroys record") {
                TestModel.destroy(record)
                expect(TestModel.all.count).to(equal(0))
            }

        }
    }
}
