import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ChapterOperationComponent } from './chapter-operation.component';

describe('ChapterOperationComponent', () => {
  let component: ChapterOperationComponent;
  let fixture: ComponentFixture<ChapterOperationComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ChapterOperationComponent]
    })
    .compileComponents();
    
    fixture = TestBed.createComponent(ChapterOperationComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
