import relationalStore from '@ohos.data.relationalStore';
import Item from '../Item'
import router from '@ohos.router';

@CustomDialog
struct CustomDeleteDialog {
  controller: CustomDialogController
  cancel: () => void
  confirm: () => void

  build() {
    Column() {
      Text('是否删除').fontSize(20).margin({ top: 10, bottom: 10 })
      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button('再想想')
          .onClick(() => {
            this.controller.close()
            this.cancel()
          }).backgroundColor(0xffffff).fontColor(Color.Black)
        Button('确定')
          .onClick(() => {
            this.controller.close()
            this.confirm()
          }).backgroundColor(0xffffff).fontColor(Color.Red)
      }.margin({ bottom: 10 })
    }
  }
}

@Entry
@Component
struct Index {
  @State items: Array<Item> = []
  timeoutId: number
  deleteId: number | undefined
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomDeleteDialog({
      cancel: this.onCancel,
      confirm: () => {
        if (!this.deleteId) {
          return
        }
        const deleteId = this.deleteId
        this.deleteId = undefined
        // 删除数据
        let predicates = new relationalStore.RdbPredicates('NOTE');
        predicates.equalTo('ID', deleteId);
        let store: relationalStore.RdbStore = globalThis.dbStore
        store.delete(predicates, (err, rows) => {
          if (err) {
            console.error(`Failed to delete data. Code:${err.code}, message:${err.message}`);
            return;
          }
          console.info(`Delete rows: ${rows}`);
          this.reloadData()
        })
      },
    }),
    alignment: DialogAlignment.Default, // 可设置dialog的对齐方式，设定显示在底部或中间等，默认为底部显示
  })

  onCancel() {
    console.info('Callback when the first button is clicked')
  }

  onAccept() {
    console.info('Callback when the second button is clicked')
  }

  aboutToAppear() {

  }

  onPageShow() {

    console.log("onPageShow=====>")

    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
    }

    this.timeoutId = setTimeout(() => {
      this.reloadData()
    }, 300)
  }

  reloadData() {
    let predicates = new relationalStore.RdbPredicates('NOTE');
    // predicates.equalTo('NAME', 'Rose');
    let store: relationalStore.RdbStore = globalThis.dbStore
    store.query(predicates, ['ID', 'CONTENT'], (err, resultSet) => {
      if (err) {
        console.error(`Failed to query data. Code:${err.code}, message:${err.message}`);
        return;
      }
      console.info(`ResultSet column names: ${resultSet.columnNames}`);
      console.info(`ResultSet rowCount : ${resultSet.rowCount}`);
      let count = resultSet.rowCount
      console.error(`count==> is ${count}`);
      this.items.splice(0, this.items.length)

      if (count == 0) {
        return
      }

      for (let index = 0; index < count; index++) {
        resultSet.goToRow(index)
        this.items.push(new Item().from(resultSet))
      }

      // resultSet.goToLastRow()
      // this.message = resultSet.getString(1)
      // console.info(`ResultSet column value: ${resultSet.getString(1)}`);

    })
  }

  build() {
    Row() {
      Column() {
        Row() {
          Text('记录列表')
            .width('33%')
            .height(50)
            .backgroundColor(Color.Black)
            .fontSize(25)
            .fontColor(0x317aff)
          if (this.items.length !== 0)
            Text('+')
              .width(50)
              .height(50)
              .fontSize(40)
              .fontColor(Color.White)
                // .bindPopup(this.handlePopup, {
                //   message: this.popContent,
                // })
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/Detail' // 目标url
                }, router.RouterMode.Standard, (err) => {
                  if (err) {
                    console.error(`Invoke pushUrl failed, code is ${err.code}, message is ${err.message}`);
                    return;
                  }
                  console.info('Invoke pushUrl succeeded.');
                });
              })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .height(70)
        .width('90%')
        .padding(10)
        .backgroundColor(Color.Black)

        Flex({ direction: FlexDirection.Column }) {
          if (this.items.length === 0) {
            Column() {
              Row() {
                Text("点击新建")
                  .fontColor(Color.Gray)
                  .fontSize(20)
              }.width('100%')
              .height(100)
              .justifyContent(FlexAlign.Center)
              .gesture(TapGesture({ count: 1 })
                .onAction((event: GestureEvent) => {
                  router.pushUrl({
                    url: 'pages/Detail', // 目标url
                  }, router.RouterMode.Standard, (err) => {
                    if (err) {
                      console.error(`Invoke pushUrl failed, code is ${err.code}, message is ${err.message}`);
                      return;
                    }
                    console.info('Invoke pushUrl succeeded.');
                  });
                }))
            }.width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
          } else {
            List() {
              ForEach(this.items, (item: Item, index: number) => {
                ListItem() {
                  Row() {
                    // Image(item.icon)
                    //   .width(40)
                    //   .height(40)
                    //   .margin(10)
                    Text(`✍️  ${item.content}`)
                      .fontSize(20)
                      .fontColor(Color.White)
                      .maxLines(2)
                      .padding(3)
                  }
                  .width('100%')
                  .height(50)
                  .justifyContent(FlexAlign.Start)
                  .alignItems(VerticalAlign.Center)
                  .backgroundColor(0x23ffffff)
                }.gesture(
                  GestureGroup(GestureMode.Exclusive,
                    // 绑定count为2的TapGesture
                    TapGesture({ count: 1 })
                      .onAction((event: GestureEvent) => {
                        router.pushUrl({
                          url: 'pages/Detail', // 目标url
                          params: item
                        }, router.RouterMode.Standard, (err) => {
                          if (err) {
                            console.error(`Invoke pushUrl failed, code is ${err.code}, message is ${err.message}`);
                            return;
                          }
                          console.info('Invoke pushUrl succeeded.');
                        });
                      }), LongPressGesture({ repeat: true })
                      .onAction((event: GestureEvent) => {
                      })
                      .onActionEnd(() => {
                        console.log("long press===>")
                        this.deleteId = item.id
                        this.dialogController.open()
                      })))
              }, item => item.id)
            }
            .width('100%')
            .divider({
              strokeWidth: 6,
              startMargin: 2,
              endMargin: 10,
              color: '#00ffffff'
            })
          }
        }.padding(10)
      }
      .width('100%')
      .height('100%').backgroundColor(Color.Black)

    }
  }
}