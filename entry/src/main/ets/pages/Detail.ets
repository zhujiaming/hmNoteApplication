import relationalStore from '@ohos.data.relationalStore';
import router from '@ohos.router';

@Entry
@Component
struct Detail {
  @State message: string = ''
  @State handlePopup: boolean = false
  @State popContent: string = ""
  ID: number | undefined

  showPop(content: string) {
    this.popContent = content
    this.handlePopup = true
    setTimeout(() => {
      this.handlePopup = false
    }, 1000)
  }

  onPageShow() {
    let predicates = new relationalStore.RdbPredicates('NOTE');
    let id = router.getParams()
    if (id && id['id']) {
      this.ID = id['id']
      predicates.equalTo("ID", this.ID as number)
    } else {
      return
    }
    setTimeout(() => {
      let store: relationalStore.RdbStore = globalThis.dbStore
      store.query(predicates, ['ID', 'CONTENT'], (err, resultSet) => {
        if (err) {
          console.error(`Failed to query data. Code:${err.code}, message:${err.message}`);
          return;
        }
        console.info(`ResultSet column names: ${resultSet.columnNames}`);
        console.info(`ResultSet rowCount : ${resultSet.rowCount}`);
        if (resultSet.rowCount == 0) {
          return
        }
        resultSet.goToLastRow()
        this.message = resultSet.getString(1)
        // console.info(`ResultSet column value: ${resultSet.getString(1)}`);
      })
    }, 300)
  }

  build() {

    Column() {
      Row() {
        Column() {
          Row() {
            Text('编辑')
              .width('33%')
              .height(50)
              .backgroundColor(Color.Black)
              .fontSize(25)
              .fontColor(0x317aff)
            Button('完成', { type: ButtonType.Normal, stateEffect: true })
              .borderRadius(8)
              .backgroundColor(0x317aff)
              .width(80)
              .height(38)
              .bindPopup(this.handlePopup, {
                message: this.popContent,
              })
              .onClick(() => {

                if (!globalThis.dbStore) {
                  this.showPop("db null")
                  return
                }

                if (!this.ID) {
                  console.log(`insert content:${this.message}`)

                  const noteContent = {
                    'CONTENT': this.message
                  };

                  globalThis.dbStore.insert('NOTE', noteContent, (err, rowId) => {
                    if (err) {
                      this.showPop("insert err")
                      console.error(`Failed to insert data. Code:${err.code}, message:${err.message}`);
                      return;
                    }
                    this.showPop("保存成功")
                    console.info(`Succeeded in inserting data. rowId:${rowId}`);
                  })
                } else {
                  console.log(`update content:${this.message}    ${this.ID}`)
                  let predicates = new relationalStore.RdbPredicates('NOTE');
                  predicates.equalTo('ID', this.ID);
                  let valueBucket = {
                    'ID': this.ID,
                    "CONTENT": this.message
                  }
                  globalThis.dbStore.update(valueBucket, predicates, (err, rows) => {
                    if (err) {
                      console.error(`Failed to update data. Code:${err.code}, message:${err.message}`);
                      return;
                    }
                    this.showPop("保存成功")
                    console.info(`Succeeded in updating data. row count: ${rows}`);
                  })
                }

                router.back()
              })
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .height(70)
          .width('90%')
          .padding(10)
          .backgroundColor(Color.Black)

          TextArea({ text: this.message, placeholder: "请输入" })
            .placeholderColor(Color.Gray)
            .focusable(true)
            .focusOnTouch(true)
            .fontSize(22)
            .fontColor(Color.White)
            .backgroundColor(Color.Black)
            .onChange((value: string) => {
              if (value.trim() != '') {
                this.message = value
              }
            })
        }
        .width('100%')
        .height('100%')
      }
      .height('100%')
      .backgroundColor(Color.Black)
    }

  }
}