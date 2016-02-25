import Quick
import Nimble
import Swifton

class MemoryModelSpec: QuickSpec {
    override func spec() {
        describe("MemoryModel") {
            beforeEach {
                TestModel.all = [MemoryModel]()
            }

            it("adds record to 'all' collection") {
                let record = TestModel.create(["name": "Saulius", "surname": "Grigaitis"])
                expect(TestModel.all).to(equal([record]))
            }

            it("finds record by id:String") {
                let record = TestModel.create(["name": "Saulius", "surname": "Grigaitis"])
                let expected = TestModel.find(String(record.id))
                expect(record).to(equal(expected))
            }

            it("finds record by id:Int") {
                let record = TestModel.create(["name": "Saulius", "surname": "Grigaitis"])
                let expected = TestModel.find(record.id)
                expect(record).to(equal(expected))
            }

            it("accesses records's attribute via subscript") {
                let record = TestModel.create(["name": "Saulius", "surname": "Grigaitis"])
                expect(String(record["name"]!)).to(equal("Saulius"))
                expect(String(record["surname"]!)).to(equal("Grigaitis"))
            }

            it("updates record") {
                let record = TestModel.create(["name": "Saulius", "surname": "Grigaitis"])
                record.update(["name": "James", "surname": "Bond"])
                expect(String(record["name"]!)).to(equal("James"))
                expect(String(record["surname"]!)).to(equal("Bond"))
            }

            it("destroys record") {
                let record = TestModel.create(["name": "Saulius", "surname": "Grigaitis"])
                TestModel.destroy(record)
                expect(TestModel.all.count).to(equal(0))
            }

        }
    }
}
