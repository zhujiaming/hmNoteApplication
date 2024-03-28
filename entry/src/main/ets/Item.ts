import relationalStore from '@ohos.data.relationalStore';

export default class Item {
  id: number;
  content: string;

  from(resultSet: relationalStore.ResultSet): Item {
    this.id = resultSet.getLong(0)
    this.content = resultSet.getString(1)
    console.log(`set id content:${this.id}   ${this.content}`)
    return this;
  }
}